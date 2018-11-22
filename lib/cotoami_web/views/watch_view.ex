defmodule CotoamiWeb.WatchView do
  use CotoamiWeb, :view
  alias CotoamiWeb.CotonomaView

  def render("index.json", %{watchlist: watchlist}) do
    render_many(watchlist, __MODULE__, "watch.json")
  end

  def render("watchlist.json", %{watchlist: watchlist}) do
    render_many(watchlist, __MODULE__, "watch.json")
  end

  def render("watch.json", %{watch: watch}) do
    %{
      id: watch.id,
      cotonoma: render_relation(watch.cotonoma, CotonomaView, "cotonoma.json"),
      last_post_timestamp: watch.last_post_timestamp |> to_unixtime()
    }
  end
end
