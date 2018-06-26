defmodule CotoamiWeb.CotoGraphController do
  use CotoamiWeb, :controller
  require Logger
  alias Bolt.Sips
  alias Cotoami.{CotoGraphService, CotonomaService, CotoService}
  alias Cotoami.Exceptions.NotFound

  def action(conn, _) do
    apply(__MODULE__, action_name(conn), [conn, conn.params, conn.assigns.amishi])
  end

  def index(conn, params, amishi) do
    case get_cotonoma_if_specified(params) do
      nil ->
        json conn, CotoGraphService.get_graph_in_amishi(Sips.conn, amishi)
      cotonoma ->
        json conn, CotoGraphService.get_graph_in_cotonoma(Sips.conn, cotonoma)
    end
  end

  def subgraph(conn, %{"cotonoma_key" => cotonoma_key}, _amishi) do
    case CotonomaService.get_by_key(cotonoma_key) do
      nil -> send_resp(conn, :not_found, "cotonoma not found: #{cotonoma_key}")
      cotonoma -> json conn, CotoGraphService.get_graph_from_cotonoma(Sips.conn, cotonoma)
    end
  end

  def pin(conn, %{"coto_ids" => coto_ids} = params, amishi) do
    cotonoma = get_cotonoma_if_specified(params)
    results =
      coto_ids
      |> CotoService.get_by_ids()
      |> Enum.filter(&(&1))
      |> Enum.map(fn(coto) ->
          case cotonoma do
            nil ->
              CotoGraphService.pin(Sips.conn, coto, amishi)
            cotonoma ->
              CotoGraphService.pin(Sips.conn, coto, cotonoma, amishi)
              broadcast_connect(
                cotonoma.coto, 
                CotoService.complement(coto, amishi), 
                amishi, 
                conn.assigns.client_id)
          end
        end)
    json conn, results
  end

  def unpin(conn, %{"coto_id" => coto_id} = params, amishi) do
    cotonoma = get_cotonoma_if_specified(params)
    coto = ensure_to_get_coto(coto_id)
    case cotonoma do
      nil -> CotoGraphService.unpin(Sips.conn, coto, amishi)
      cotonoma -> 
        CotoGraphService.unpin(Sips.conn, coto, cotonoma, amishi)
        broadcast_disconnect(cotonoma.coto_id, coto.id, amishi, conn.assigns.client_id)
    end
    text conn, "ok"
  end

  def connect(conn, %{"start_id" => start_id, "end_ids" => end_ids} = params, amishi) do
    cotonoma = get_cotonoma_if_specified(params)
    start_coto = ensure_to_get_coto(start_id)
    result =
      end_ids
      |> CotoService.get_by_ids()
      |> Enum.filter(&(&1))
      |> Enum.map(fn(end_coto) ->
          case cotonoma do
            nil ->
              CotoGraphService.connect(Sips.conn, start_coto, end_coto, amishi)
            cotonoma ->
              CotoGraphService.connect(Sips.conn, start_coto, end_coto, amishi, cotonoma)
          end
          broadcast_connect(
            CotoService.complement(start_coto, amishi), 
            CotoService.complement(end_coto, amishi), 
            amishi, 
            conn.assigns.client_id)
        end)
    json conn, result
  end

  def disconnect(conn, %{"start_id" => start_id, "end_id" => end_id}, amishi) do
    start_coto = ensure_to_get_coto(start_id)
    end_coto = ensure_to_get_coto(end_id)
    CotoGraphService.disconnect(Sips.conn, start_coto, end_coto, amishi)
    broadcast_disconnect(start_coto.id, end_coto.id, amishi, conn.assigns.client_id)
    text conn, "ok"
  end

  def reorder(conn, %{"end_ids" => end_ids} = params, amishi) do
    case params do
      %{"start_id" => start_id} ->
        start_coto = ensure_to_get_coto(start_id)
        CotoGraphService.reorder_connections(Sips.conn, start_coto, end_ids, amishi)
        broadcast_reorder(start_id, end_ids, amishi, conn.assigns.client_id)
      _ -> 
        case get_cotonoma_if_specified(params) do
          nil ->
            CotoGraphService.reorder_connections(Sips.conn, amishi, end_ids)
          cotonoma ->
            cotonoma_coto = CotoService.complement_amishi(cotonoma.coto, amishi)
            CotoGraphService.reorder_connections(Sips.conn, cotonoma_coto, end_ids, amishi)
            broadcast_reorder(cotonoma_coto.id, end_ids, amishi, conn.assigns.client_id)
        end
    end
    text conn, "ok"
  end

  defp ensure_to_get_coto(coto_id) do
    case CotoService.get(coto_id) do
      nil -> raise NotFound, "coto: #{coto_id}"
      coto -> coto
    end
  end

  defp get_cotonoma_if_specified(params) do
    case params do
      %{"cotonoma_key" => cotonoma_key} ->
        CotonomaService.get_by_key!(cotonoma_key)
      _ -> nil
    end
  end
end
