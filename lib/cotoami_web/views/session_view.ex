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
      app_version: Application.spec(:cotoami, :vsn) |> to_string(),
      amishi: render_relation(amishi, AmishiView, "amishi.json"),
      token: token,
      websocket_url: websocket_url,
      lang: lang
    }
  end
end
