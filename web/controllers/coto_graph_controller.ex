defmodule Cotoami.CotoGraphController do
  use Cotoami.Web, :controller
  require Logger
  alias Cotoami.CotoGraphService
  alias Cotoami.CotonomaService
  alias Cotoami.Coto

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

  def pin(conn, %{"coto_id" => coto_id}, amishi) do
    coto = Coto.for_amishi(Coto, amishi.id) |> Repo.get!(coto_id)
    case coto do
      nil -> send_resp(conn, :not_found, "coto not found: #{coto_id}")
      coto -> json conn, CotoGraphService.pin(coto, amishi)
    end
  end

  def unpin(conn, %{"coto_id" => coto_id}, amishi) do
    coto = Coto.for_amishi(Coto, amishi.id) |> Repo.get!(coto_id)
    case coto do
      nil -> send_resp(conn, :not_found, "coto not found: #{coto_id}")
      coto -> json conn, CotoGraphService.unpin(coto, amishi)
    end
  end

  def pin_to_cotonoma(conn, %{"cotonoma_key" => cotonoma_key, "coto_id" => coto_id}, amishi) do
    cotonoma = CotonomaService.get_by_key(cotonoma_key, amishi.id)
    coto = Coto.for_amishi(Coto, amishi.id) |> Repo.get!(coto_id)
    if cotonoma && coto do
      json conn, CotoGraphService.pin(coto, cotonoma, amishi)
    else
      send_resp(conn, :not_found, "cotonoma or coto not found")
    end
  end

  def unpin_from_cotonoma(conn, %{"cotonoma_key" => cotonoma_key, "coto_id" => coto_id}, amishi) do
    cotonoma = CotonomaService.get_by_key(cotonoma_key, amishi.id)
    coto = Coto.for_amishi(Coto, amishi.id) |> Repo.get!(coto_id)
    if cotonoma && coto do
      json conn, CotoGraphService.unpin(coto, cotonoma)
    else
      send_resp(conn, :not_found, "cotonoma or coto not found")
    end
  end
end
