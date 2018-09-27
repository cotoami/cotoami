defmodule CotoamiWeb.DatabaseController do
  use CotoamiWeb, :controller
  require Logger
  alias Bolt.Sips
  alias Cotoami.{Amishi, Coto, Cotonoma, CotoService, CotoGraphService}
  alias CotoamiWeb.{AmishiView, CotoView}

  def action(conn, _) do
    apply(__MODULE__, action_name(conn), [conn, conn.params, conn.assigns.amishi])
  end

  def export(conn, _params, amishi) do
    data = %{
      amishi:
        Phoenix.View.render_one(amishi, AmishiView, "export.json"),
      cotos:
        amishi
        |> CotoService.export_by_amishi()
        |> Phoenix.View.render_many(CotoView, "export.json"),
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
          %{
            "cotos" => cotos_json,
            "connections" => connections_json,
            "amishi" => %{"id" => _} = amishi_json
          } ->
            try do
              result = import_by_amishi(cotos_json, connections_json, amishi_json, amishi)
              json conn, result
            rescue
              e -> 
                Logger.error "Import error: #{inspect e}"
                Logger.info Exception.format_stacktrace(System.stacktrace())
                send_resp(conn, :bad_request, Exception.message(e))
            end
          _ ->
            send_resp(conn, :bad_request, "Invalid data structure.")
        end
      {:error, _} ->
        send_resp(conn, :bad_request, "Invalid JSON text.")
    end
  end

  defp import_by_amishi(cotos_json, connections_json, amishi_json, %Amishi{} = amishi) do
    cotonoma_ids =
      cotos_json 
      |> Enum.map(&(get_in(&1, ["cotonoma", "id"])))
      |> Enum.reject(&is_nil/1)
    {coto_inserts, coto_updates, cotonomas, coto_rejected} =
      import_cotos(cotos_json, cotonoma_ids, amishi, {0, 0, 0, []})
    {connection_ok, connection_rejected} =
      import_connections(connections_json, amishi_json, amishi, {0, []})
    %{
      cotos: %{
        inserts: coto_inserts,
        updates: coto_updates,
        cotonomas: cotonomas,
        rejected: coto_rejected
      },
      connections: %{
        ok: connection_ok,
        rejected: connection_rejected
      }
    }
  end

  defp import_cotos(
    cotos_json,
    cotonoma_ids, 
    %Amishi{} = amishi,
    {_inserts, _updates, _cotonomas, _rejected} = stats
  ) do
    {pendings, stats} =
      Enum.reduce(cotos_json, {[], stats},
        fn(coto_json, {pendings, stats}) ->
          posted_in_id = coto_json["posted_in_id"]

          if posted_in_id == nil or Repo.get(Cotonoma, posted_in_id) != nil do
            # import a coto
            {pendings, import_coto(coto_json, stats, amishi)}
          else
            if Enum.member?(cotonoma_ids, posted_in_id) do
              # put in pending until the cotonoma is imported
              {[coto_json | pendings], stats}
            else
              # reject for missing cotonoma
              reject = %{id: coto_json["id"], reason: "cotonoma not found: #{posted_in_id}"}
              {inserts, updates, cotonomas, rejected} = stats
              {pendings, {inserts, updates, cotonomas, [reject | rejected]}}
            end
          end
        end
      )

    if Enum.empty?(pendings) do
      # done!
      stats
    else
      # retry pending data
      import_cotos(pendings, cotonoma_ids, amishi, stats)
    end
  end

  defp import_coto(
    coto_json,
    {inserts, updates, cotonomas, rejected},
    %Amishi{} = amishi
  ) do
    coto_id = coto_json["id"]
    case Repo.get(Coto, coto_id) do
      nil ->
        changeset = Coto.changeset_to_import(%Coto{}, coto_json, amishi)
        case Repo.insert(changeset) do
          {:ok, _} ->
            cotonomas = import_cotonoma(coto_json, cotonomas, amishi)
            {inserts + 1, updates, cotonomas, rejected}
          {:error, changeset} ->
            reject = %{id: coto_id, reason: inspect(changeset.errors)}
            {inserts, updates, cotonomas, [reject | rejected]}
        end
      coto ->
        changeset = Coto.changeset_to_import(coto, coto_json, amishi)
        case Repo.update(changeset) do
          {:ok, _} ->
            cotonomas = import_cotonoma(coto_json, cotonomas, amishi)
            {inserts, updates + 1, cotonomas, rejected}
          {:error, changeset} ->
            reject = %{id: coto_id, reason: inspect(changeset.errors)}
            {inserts, updates, cotonomas, [reject | rejected]}
        end
    end
  end

  defp import_cotonoma(%{"as_cotonoma" => false}, cotonomas, _) do
    cotonomas
  end
  defp import_cotonoma(
    %{"as_cotonoma" => true, "cotonoma" => %{"id" => cotonoma_id}} = coto_json,
    cotonomas,
    %Amishi{} = amishi
  ) do
    changeset =
      case Repo.get(Cotonoma, cotonoma_id) do
        nil -> Cotonoma.changeset_to_import(%Cotonoma{}, coto_json, amishi)
        cotonoma -> Cotonoma.changeset_to_import(cotonoma, coto_json, amishi)
      end
    try do
      Repo.insert_or_update!(changeset)
      cotonomas + 1
    rescue
      e in Ecto.ConstraintError ->
        case e.constraint do
          "cotonomas_name_owner_id_index" ->
            # credo:disable-for-next-line Credo.Check.Warning.RaiseInsideRescue
            raise "Cotonoma \"#{coto_json["content"]}\" already exists."
          constraint ->
            # credo:disable-for-next-line Credo.Check.Warning.RaiseInsideRescue
            raise "#{constraint}: #{inspect coto_json}"
        end
    end
  end

  defp import_connections(
    connections_json,
    amishi_json,
    %Amishi{} = amishi,
    {_ok, _rejected} = stats
  ) do
    bolt_conn = Sips.conn
    Enum.reduce(connections_json, stats,
      fn(connection_json, {ok, rejected}) ->
        {start_id, end_id} = {connection_json["start"], connection_json["end"]}
        source = CotoService.get(start_id)
        target = CotoService.get(end_id)
        cond do
          target && start_id == amishi_json["id"] ->
            CotoGraphService.import_connection(
              bolt_conn, target, connection_json, amishi)
            {ok + 1, rejected}

          target && source ->
            CotoGraphService.import_connection(
              bolt_conn, source, target, connection_json, amishi)
            {ok + 1, rejected}

          true ->
            reject = %{id: "#{start_id} => #{end_id}", reason: "coto not found"}
            {ok, [reject | rejected]}
        end
      end
    )
  end
end
