defmodule CotoamiWeb.WatchController do
  use CotoamiWeb, :controller
  require Logger
  alias Cotoami.WatchService
  alias Cotoami.CotonomaService

  def action(conn, _) do
    apply(__MODULE__, action_name(conn), [conn, conn.params, conn.assigns.amishi])
  end

  def index(conn, _params, amishi) do
    watchlist = WatchService.get_watchlist(amishi)
    render(conn, "index.json", %{watchlist: watchlist})
  end

  def create(conn, %{"cotonoma_key" => cotonoma_key}, amishi) do
    cotonoma = CotonomaService.get_by_key!(cotonoma_key)

    if cotonoma.shared do
      WatchService.get_or_create!(amishi, cotonoma)
      watchlist = WatchService.get_watchlist(amishi)
      render(conn, "watchlist.json", %{watchlist: watchlist})
    else
      send_resp(conn, :forbidden, "The cotonoma is not shared.")
    end
  end
end
