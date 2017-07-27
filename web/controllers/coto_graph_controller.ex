defmodule Cotoami.CotoGraphController do
  use Cotoami.Web, :controller
  require Logger
  alias Cotoami.CotoGraphService
  alias Cotoami.CotonomaService

  def action(conn, _) do
    apply(__MODULE__, action_name(conn), [conn, conn.params, conn.assigns.amishi])
  end

  def index(conn, _params, amishi) do
    json conn, CotoGraphService.get_graph(amishi)
  end

  def cotonoma(conn, %{"cotonoma_key" => cotonoma_key}, amishi) do
    case CotonomaService.get_by_key(cotonoma_key, amishi.id) do
      nil ->
        send_resp(conn, :not_found, "cotonoma not found: #{cotonoma_key}")
      cotonoma ->
        json conn, CotoGraphService.get_graph(cotonoma)
    end
  end
end
