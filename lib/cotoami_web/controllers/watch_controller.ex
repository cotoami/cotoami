defmodule CotoamiWeb.WatchController do
  use CotoamiWeb, :controller
  require Logger
  alias Cotoami.WatchService

  def index(conn, _params, amishi) do
    render(conn, "index.json", WatchService.get_watchlist(amishi))
  end
end
