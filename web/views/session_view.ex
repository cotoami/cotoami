defmodule Cotoami.SessionView do
  use Cotoami.Web, :view
  alias Cotoami.AmishiView

  def render("session.json", %{amishi: amishi, token: token, websocket_url: websocket_url}) do
    amishi
    |> render_one(AmishiView, "amishi.json")
    |> Map.put(:token, token)
    |> Map.put(:websocket_url, websocket_url)
  end
end
