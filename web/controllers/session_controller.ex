defmodule Cotoami.SessionController do
  use Cotoami.Web, :controller
  require Logger
  alias Cotoami.SigninController

  def index(conn, _params) do
    case conn.assigns do
      %{amishi: amishi} ->
        render(conn, "session.json",
          amishi: amishi,
          token: Phoenix.Token.sign(conn, "amishi", amishi.id),
          websocket_url: get_websocket_url()
        )
      _ ->
        conn
        |> put_status(:not_found)
        |> json(%{
          signup_enabled: SigninController.signup_enabled
        })
    end
  end

  defp get_websocket_url() do
    %{scheme: scheme, host: host, port: port} = Cotoami.Endpoint.struct_url()
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
