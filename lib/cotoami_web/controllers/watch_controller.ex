defmodule CotoamiWeb.WatchController do
  use CotoamiWeb, :controller
  require Logger
  alias Cotoami.WatchService
  alias Cotoami.CotonomaService

  def index(conn, _params, amishi) do
    watchlist = WatchService.get_watchlist(amishi)
    render(conn, "index.json", %{watchlist: watchlist})
  end

  def create(conn, %{"cotonoma_id" => cotonoma_id}, amishi) do
    cotonoma = CotonomaService.get!(cotonoma_id)

    if cotonoma.shared do
      WatchService.get_or_create!(amishi, cotonoma)
      watchlist = WatchService.get_watchlist(amishi)
      render(conn, "watchlist.json", %{watchlist: watchlist})
    else
      send_resp(conn, :forbidden, "The cotonoma is not shared.")
    end
  end
end
