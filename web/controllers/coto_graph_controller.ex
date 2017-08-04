defmodule Cotoami.CotoGraphController do
  use Cotoami.Web, :controller
  require Logger
  alias Cotoami.{CotoGraphService, CotonomaService, CotoService, Coto}

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

  def pin(conn, %{"coto_ids" => coto_ids}, amishi) do
    results =
      coto_ids
      |> CotoService.get_by_ids()
      |> Enum.filter(&(&1))
      |> Enum.map(&(CotoGraphService.pin(&1, amishi)))
    json conn, results
  end

  def unpin(conn, %{"coto_id" => coto_id}, amishi) do
    coto = Coto |> Coto.for_amishi(amishi.id) |> Repo.get!(coto_id)
    case coto do
      nil -> send_resp(conn, :not_found, "coto not found: #{coto_id}")
      coto -> json conn, CotoGraphService.unpin(coto, amishi)
    end
  end

  def pin_to_cotonoma(conn, %{"cotonoma_key" => cotonoma_key, "coto_ids" => coto_ids}, amishi) do
    case CotonomaService.get_by_key(cotonoma_key, amishi.id) do
      nil -> send_resp(conn, :not_found, "cotonoma not found: #{cotonoma_key}")
      cotonoma ->
        results =
          coto_ids
          |> CotoService.get_by_ids()
          |> Enum.filter(&(&1))
          |> Enum.map(&(CotoGraphService.pin(&1, cotonoma, amishi)))
        json conn, results
    end
  end

  def unpin_from_cotonoma(conn, %{"cotonoma_key" => cotonoma_key, "coto_id" => coto_id}, amishi) do
    cotonoma = CotonomaService.get_by_key(cotonoma_key, amishi.id)
    coto = Coto |> Coto.for_amishi(amishi.id) |> Repo.get!(coto_id)
    if cotonoma && coto do
      json conn, CotoGraphService.unpin(coto, cotonoma)
    else
      send_resp(conn, :not_found, "cotonoma or coto not found")
    end
  end

  def connect(conn, %{"start_id" => start_id, "end_ids" => end_ids}, amishi) do
    case CotoService.get(start_id) do
      nil -> send_resp(conn, :not_found, "start coto not found: #{start_id}")
      start_coto ->
        results =
          end_ids
          |> CotoService.get_by_ids()
          |> Enum.filter(&(&1))
          |> Enum.map(&(CotoGraphService.connect(start_coto, &1, amishi)))
      json conn, results
    end
  end
end
