defmodule CotoamiWeb.SessionView do
  use CotoamiWeb, :view
  alias CotoamiWeb.AmishiView

  def render("session.json", %{
        amishi: amishi,
        token: token,
        websocket_url: websocket_url,
        lang: lang
      }) do
    %{
      amishi: render_relation(amishi, AmishiView, "amishi.json"),
      token: token,
      websocket_url: websocket_url,
      lang: lang
    }
  end
end
