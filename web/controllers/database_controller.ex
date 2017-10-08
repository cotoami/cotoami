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
      {coto_inserts, coto_updates} = import_cotos(cotos, {0, 0}, amishi)
      %{
        cotos: %{inserts: coto_inserts, updates: coto_updates},
        connections: %{ok: 0, coto_not_found: 0}
      }
    end)
  end

  defp import_cotos(cotos, {_inserts, _updates} = results, %Amishi{} = amishi) do
    {pendings, results} =
      Enum.reduce(cotos, {[], results},
        fn(coto, {pendings, results}) ->
          posted_in_id = coto["posted_in"]["id"]
          if posted_in_id && Repo.get(Cotonoma, posted_in_id) == nil do
            {[coto | pendings], results}
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

  defp import_coto(coto, {inserts, updates}, %Amishi{} = amishi) do
    {changeset, results} =
      case Repo.get(Coto, coto["id"]) do
        nil ->
          {Coto.changeset_to_import(%Coto{}, coto, amishi),
            {inserts + 1, updates}}
        coto ->
          {Coto.changeset_to_import(coto, coto, amishi),
            {inserts, updates + 1}}
      end
    Repo.insert_or_update!(changeset)
    results
  end
end
