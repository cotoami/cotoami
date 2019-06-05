defmodule CotoamiWeb.SessionController do
  use CotoamiWeb, :controller
  require Logger
  alias CotoamiWeb.{EmailAuthController, OAuth2Controller}

  def index(conn, _params) do
    case conn.assigns do
      %{amishi: amishi} ->
        render(
          conn,
          "session.json",
          amishi: amishi,
          token: Phoenix.Token.sign(conn, "amishi", amishi.id),
          websocket_url: get_websocket_url(),
          lang: conn.assigns[:lang]
        )

      _ ->
        conn
        |> put_status(:not_found)
        |> json(%{
          signup_enabled: EmailAuthController.signup_enabled(),
          oauth_providers: OAuth2Controller.providers()
        })
    end
  end

  defp get_websocket_url() do
    %{scheme: scheme, host: host, port: port} = CotoamiWeb.Endpoint.struct_url()

    cond do
      scheme == "https" ->
        "wss://#{host}/socket/websocket"

      port == 80 ->
        "ws://#{host}/socket/websocket"

      true ->
        "ws://#{host}:#{port}/socket/websocket"
    end
  end

  def signout(conn, _params) do
    conn
    |> configure_session(drop: true)
    |> redirect(to: "/")
  end
end
