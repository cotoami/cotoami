defmodule Cotoami.CotoGraphController do
  use Cotoami.Web, :controller
  require Logger
  alias Cotoami.{CotoGraphService, CotonomaService, CotoService, Coto, Amishi}
  alias Cotoami.Exceptions.NotFound

  def action(conn, _) do
    apply(__MODULE__, action_name(conn), [conn, conn.params, conn.assigns.amishi])
  end

  def index(conn, _params, amishi) do
    json conn, CotoGraphService.get_graph(amishi)
  end

  def cotonoma(conn, %{"cotonoma_key" => cotonoma_key}, amishi) do
    case CotonomaService.get_by_key(cotonoma_key, amishi.id) do
      nil -> send_resp(conn, :not_found, "cotonoma not found: #{cotonoma_key}")
      cotonoma -> json conn, CotoGraphService.get_graph(cotonoma)
    end
  end

  def subgraph(conn, %{"cotonoma_key" => cotonoma_key}, amishi) do
    case CotonomaService.get_by_key(cotonoma_key, amishi.id) do
      nil -> send_resp(conn, :not_found, "cotonoma not found: #{cotonoma_key}")
      cotonoma -> json conn, CotoGraphService.get_subgraph(cotonoma)
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
              CotoGraphService.pin(coto, amishi)
            cotonoma ->
              CotoGraphService.pin(coto, cotonoma, amishi)
          end
        end)
    json conn, results
  end

  def unpin(conn, %{"coto_id" => coto_id} = params, amishi) do
    cotonoma = get_cotonoma_if_specified(params, amishi)
    case CotoService.get(coto_id) do
      nil -> send_resp(conn, :not_found, "coto not found: #{coto_id}")
      coto ->
        case cotonoma do
          nil -> json conn, CotoGraphService.unpin(coto, amishi)
          cotonoma -> json conn, CotoGraphService.unpin(coto, cotonoma)
        end
    end
  end

  def connect(conn, %{"start_id" => start_id, "end_ids" => end_ids} = params, amishi) do
    cotonoma = get_cotonoma_if_specified(params, amishi)
    case CotoService.get(start_id) do
      nil -> send_resp(conn, :not_found, "start coto not found: #{start_id}")
      start_coto ->
        results =
          end_ids
          |> CotoService.get_by_ids()
          |> Enum.filter(&(&1))
          |> Enum.map(fn(end_coto) ->
              case cotonoma do
                nil ->
                  CotoGraphService.connect(start_coto, end_coto, amishi)
                cotonoma ->
                  CotoGraphService.connect(start_coto, end_coto, amishi, cotonoma)
              end
            end)
      json conn, results
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
