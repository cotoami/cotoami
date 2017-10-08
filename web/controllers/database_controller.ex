defmodule Cotoami.DatabaseController do
  use Cotoami.Web, :controller
  require Logger
  alias Bolt.Sips
  alias Cotoami.{
    Amishi, Coto, Cotonoma,
    CotoService, CotoGraphService,
    AmishiView, CotoView
  }

  def action(conn, _) do
    apply(__MODULE__, action_name(conn), [conn, conn.params, conn.assigns.amishi])
  end

  def export(conn, _params, amishi) do
    data = %{
      amishi:
        Phoenix.View.render_one(amishi, AmishiView, "amishi.json"),
      cotos:
        amishi
        |> CotoService.export_by_amishi()
        |> Phoenix.View.render_many(CotoView, "coto.json"),
      connections:
        CotoGraphService.export_connections_by_amishi(Sips.conn, amishi)
    }

    conn
    |> put_resp_content_type("application/octet-stream", nil)
    |> put_resp_header(
      "content-disposition",
      ~s[attachment; filename="cotoami-export.json"])
    |> send_resp(200, Poison.encode!(data, pretty: true))
  end

  def import(conn, %{"data" => data}, %{owner: true} = amishi) do
    case Poison.decode(data) do
      {:ok, json_data} ->
        case json_data do
          %{"cotos" => cotos, "connections" => connections} ->
            import_by_amishi(cotos, connections, amishi)
            json conn, %{cotos: 1, connections: 2}
          _ ->
            conn
            |> put_status(:bad_request)
            |> text("Invalid data structure.")
        end
      {:error, _} ->
        conn
        |> put_status(:bad_request)
        |> text("Invalid JSON text.")
    end
  end

  defp import_by_amishi(cotos, _connections, %Amishi{} = amishi) do
    Repo.transaction(fn ->
      {coto_inserts, coto_updates, coto_rejected} =
        import_cotos(cotos, {0, 0, []}, amishi)
      %{
        cotos: %{
          inserts: coto_inserts,
          updates: coto_updates,
          rejected: coto_rejected
        },
        connections: %{ok: 0, rejected: []}
      }
    end)
  end

  defp import_cotos(cotos, {_inserts, _updates, _rejected} = results, %Amishi{} = amishi) do
    {pendings, results} =
      Enum.reduce(cotos, {[], results},
        fn(coto, {pendings, {inserts, updates, rejected} = results}) ->
          posted_in_id = coto["posted_in"]["id"]
          if posted_in_id && Repo.get(Cotonoma, posted_in_id) == nil do
            if Enum.any?(cotos, &(&1["cotonoma_id"] == posted_in_id)) do
              # put this coto in pending until the posted_in cotonoma, which is
              # found in the import data, is imported
              {[coto | pendings], results}
            else
              # reject this coto because the posted_in cotonoma is not found in
              # both the db and import data
              reject = %{id: coto["id"], reason: "cotonoma not found: #{posted_in_id}"}
              {pendings, {inserts, updates, [reject | rejected]}}
            end
          else
            {pendings, import_coto(coto, results, amishi)}
          end
        end
      )

    if Enum.empty?(pendings) do
      results
    else
      import_cotos(pendings, results, amishi)
    end
  end

  defp import_coto(coto, {inserts, updates, rejected}, %Amishi{} = amishi) do
    coto_id = coto["id"]
    case Repo.get(Coto, coto_id) do
      nil ->
        changeset = Coto.changeset_to_import(%Coto{}, coto, amishi)
        case Repo.insert(changeset) do
          {:ok, _} -> {inserts + 1, updates, rejected}
          {:error, changeset} ->
            reject = %{id: coto_id, reason: inspect(changeset.errors)}
            {inserts, updates, [reject | rejected]}
        end
      coto ->
        changeset = Coto.changeset_to_import(coto, coto, amishi)
        case Repo.update(changeset) do
          {:ok, _} -> {inserts, updates + 1, rejected}
          {:error, changeset} ->
            reject = %{id: coto_id, reason: inspect(changeset.errors)}
            {inserts, updates, [reject | rejected]}
        end
    end
  end
end
