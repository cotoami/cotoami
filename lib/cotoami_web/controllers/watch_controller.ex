defmodule CotoamiWeb.WatchController do
  use CotoamiWeb, :controller
  require Logger
  alias Cotoami.WatchService
  alias Cotoami.CotonomaService

  def action(conn, _) do
    apply(__MODULE__, action_name(conn), [conn, conn.params, conn.assigns.amishi])
  end

  def index(conn, _params, amishi) do
    render(conn, "index.json", %{watchlist: WatchService.get_watchlist(amishi)})
  end

  def create(conn, %{"cotonoma_key" => cotonoma_key}, amishi) do
    cotonoma = CotonomaService.get_by_key!(cotonoma_key)

    if cotonoma.shared do
      WatchService.get_or_create!(amishi, cotonoma)
      render(conn, "watchlist.json", %{watchlist: WatchService.get_watchlist(amishi)})
    else
      send_resp(conn, :forbidden, "The cotonoma is not shared.")
    end
  end

  def delete(conn, %{"cotonoma_key" => cotonoma_key}, amishi) do
    WatchService.delete!(amishi, CotonomaService.get_by_key!(cotonoma_key))
    render(conn, "watchlist.json", %{watchlist: WatchService.get_watchlist(amishi)})
  end
end
