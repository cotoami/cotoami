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
          %{"cotos" => cotos_json, "connections" => connections_json} ->
            case import_by_amishi(cotos_json, connections_json, amishi) do
              {:ok, result} -> json conn, result
              _ ->
                conn
                |> put_status(:internal_server_error)
                |> text("Transaction error.")
            end
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

  defp import_by_amishi(cotos_json, _connections_json, %Amishi{} = amishi) do
    Repo.transaction(fn ->
      {coto_inserts, coto_updates, coto_rejected} =
        import_cotos(cotos_json, {0, 0, []}, amishi)
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

  defp import_cotos(
    cotos_json,
    {_inserts, _updates, _rejected} = results,
    %Amishi{} = amishi
  ) do
    {pendings, results} =
      Enum.reduce(cotos_json, {[], results},
        fn(coto_json, {pendings, {inserts, updates, rejected} = results}) ->
          posted_in_id = coto_json["posted_in"]["id"]
          if posted_in_id && Repo.get(Cotonoma, posted_in_id) == nil do
            if Enum.any?(cotos_json, &(&1["cotonoma_id"] == posted_in_id)) do
              # put this coto_json in pending until the posted_in cotonoma, which is
              # found in the import data, is imported
              {[coto_json | pendings], results}
            else
              # reject this coto_json because the posted_in cotonoma is not found in
              # both the db and import data
              reject = %{id: coto_json["id"], reason: "cotonoma not found: #{posted_in_id}"}
              {pendings, {inserts, updates, [reject | rejected]}}
            end
          else
            {pendings, import_coto(coto_json, results, amishi)}
          end
        end
      )

    if Enum.empty?(pendings) do
      results
    else
      import_cotos(pendings, results, amishi)
    end
  end

  defp import_coto(coto_json, {inserts, updates, rejected}, %Amishi{} = amishi) do
    coto_id = coto_json["id"]
    case Repo.get(Coto, coto_id) do
      nil ->
        changeset = Coto.changeset_to_import(%Coto{}, coto_json, amishi)
        case Repo.insert(changeset) do
          {:ok, _} ->
            import_cotonoma(coto_json, amishi)
            {inserts + 1, updates, rejected}
          {:error, changeset} ->
            reject = %{id: coto_id, reason: inspect(changeset.errors)}
            {inserts, updates, [reject | rejected]}
        end
      coto ->
        changeset = Coto.changeset_to_import(coto, coto_json, amishi)
        case Repo.update(changeset) do
          {:ok, _} ->
            import_cotonoma(coto_json, amishi)
            {inserts, updates + 1, rejected}
          {:error, changeset} ->
            reject = %{id: coto_id, reason: inspect(changeset.errors)}
            {inserts, updates, [reject | rejected]}
        end
    end
  end

  defp import_cotonoma(%{"as_cotonoma" => false} = coto_json, %Amishi{} = amishi) do
  end
  defp import_cotonoma(%{"as_cotonoma" => true} = coto_json, %Amishi{} = amishi) do
    cotonoma_id = coto_json["cotonoma_id"]
    changeset =
      case Repo.get(Cotonoma, cotonoma_id) do
        nil -> Cotonoma.changeset_to_import(%Cotonoma{}, coto_json, amishi)
        cotonoma -> Cotonoma.changeset_to_import(cotonoma, coto_json, amishi)
      end
    Repo.insert_or_update!(changeset)
  end
end
