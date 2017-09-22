defmodule Cotoami.CotoGraphController do
  use Cotoami.Web, :controller
  require Logger
  alias Bolt.Sips
  alias Cotoami.{CotoGraphService, CotonomaService, CotoService, Amishi}
  alias Cotoami.Exceptions.NotFound

  def action(conn, _) do
    apply(__MODULE__, action_name(conn), [conn, conn.params, conn.assigns.amishi])
  end

  def index(conn, params, amishi) do
    case get_cotonoma_if_specified(params, amishi) do
      nil ->
        json conn, CotoGraphService.get_graph!(Sips.conn, amishi)
      cotonoma ->
        json conn, CotoGraphService.get_graph!(Sips.conn, cotonoma)
    end
  end

  def subgraph(conn, %{"cotonoma_key" => cotonoma_key}, amishi) do
    case CotonomaService.get_by_key(cotonoma_key, amishi.id) do
      nil -> send_resp(conn, :not_found, "cotonoma not found: #{cotonoma_key}")
      cotonoma -> json conn, CotoGraphService.get_subgraph!(Sips.conn, cotonoma)
    end
  end

  def pin(conn, %{"coto_ids" => coto_ids} = params, amishi) do
    cotonoma = get_cotonoma_if_specified(params, amishi)
    results =
      coto_ids
      |> CotoService.get_by_ids()
      |> Enum.filter(&(&1))
      |> Enum.map(fn(coto) ->
          case cotonoma do
            nil ->
              CotoGraphService.pin!(Sips.conn, coto, amishi)
            cotonoma ->
              CotoGraphService.pin!(Sips.conn, coto, cotonoma, amishi)
          end
        end)
    json conn, results
  end

  def unpin(conn, %{"coto_id" => coto_id} = params, amishi) do
    cotonoma = get_cotonoma_if_specified(params, amishi)
    coto = ensure_to_get_coto(coto_id)
    case cotonoma do
      nil -> json conn, CotoGraphService.unpin!(Sips.conn, coto, amishi)
      cotonoma -> json conn, CotoGraphService.unpin!(Sips.conn, coto, cotonoma)
    end
  end

  def connect(conn, %{"start_id" => start_id, "end_ids" => end_ids} = params, amishi) do
    cotonoma = get_cotonoma_if_specified(params, amishi)
    start_coto = ensure_to_get_coto(start_id)
    result =
      end_ids
      |> CotoService.get_by_ids()
      |> Enum.filter(&(&1))
      |> Enum.map(fn(end_coto) ->
          case cotonoma do
            nil ->
              CotoGraphService.connect!(Sips.conn, start_coto, end_coto, amishi)
            cotonoma ->
              CotoGraphService.connect!(Sips.conn, start_coto, end_coto, amishi, cotonoma)
          end
        end)
    json conn, result
  end

  def disconnect(conn, %{"start_id" => start_id, "end_id" => end_id} = params, amishi) do
    cotonoma = get_cotonoma_if_specified(params, amishi)
    start_coto = ensure_to_get_coto(start_id)
    end_coto = ensure_to_get_coto(end_id)
    result =
      case cotonoma do
        nil ->
          CotoGraphService.disconnect!(Sips.conn, start_coto, end_coto, amishi)
        cotonoma ->
          CotoGraphService.disconnect!(Sips.conn, start_coto, end_coto, amishi, cotonoma)
      end
    json conn, result
  end

  defp ensure_to_get_coto(coto_id) do
    case CotoService.get(coto_id) do
      nil -> raise NotFound, "coto: #{coto_id}"
      coto -> coto
    end
  end

  defp get_cotonoma_if_specified(params, %Amishi{id: amishi_id}) do
    case params do
      %{"cotonoma_key" => cotonoma_key} ->
        case CotonomaService.get_by_key(cotonoma_key, amishi_id) do
          nil -> raise NotFound, "cotonoma: #{cotonoma_key}"
          cotonoma -> cotonoma
        end
      _ -> nil
    end
  end
end
