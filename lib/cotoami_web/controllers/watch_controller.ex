defmodule CotoamiWeb.WatchController do
  use CotoamiWeb, :controller
  require Logger
  alias Cotoami.Cotonoma
  alias Cotoami.WatchService
  alias Cotoami.CotonomaService

  def action(conn, _) do
    apply(__MODULE__, action_name(conn), [conn, conn.params, conn.assigns.amishi])
  end

  def index(conn, _params, amishi) do
    render(conn, "index.json", %{watchlist: WatchService.get_watchlist(amishi)})
  end

  def create(conn, %{"cotonoma_key" => key}, amishi) do
    cotonoma = CotonomaService.get_accessible_by_key!(key, amishi)

    if cotonoma.shared do
      WatchService.get_or_create!(amishi, cotonoma)
      render(conn, "watchlist.json", %{watchlist: WatchService.get_watchlist(amishi)})
    else
      send_resp(conn, :forbidden, "The cotonoma is not shared.")
    end
  end

  def update(conn, %{"cotonoma_key" => key, "last_post_timestamp" => timestamp}, amishi) do
    cotonoma = CotonomaService.get_accessible_by_key!(key, amishi)
    timestamp = DateTime.from_unix!(timestamp, :millisecond)
    watch = WatchService.update_last_post_timestamp!(amishi, cotonoma, timestamp)
    render(conn, "watch.json", %{watch: watch})
  end

  def delete(conn, %{"cotonoma_key" => key}, amishi) do
    cotonoma = Repo.get_by!(Cotonoma, key: key)
    WatchService.delete!(amishi, cotonoma)
    render(conn, "watchlist.json", %{watchlist: WatchService.get_watchlist(amishi)})
  end
end
