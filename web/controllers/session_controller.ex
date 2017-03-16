defmodule Cotoami.SessionController do
  use Cotoami.Web, :controller
  require Logger
  alias Cotoami.AmishiService
  
  def index(conn, _params) do
    case conn.assigns do
      %{amishi: amishi} ->
        render(conn, "session.json", 
          amishi: AmishiService.append_gravatar_profile(amishi),
          token: Phoenix.Token.sign(conn, "amishi", amishi.id)
        )
      _ ->
        send_resp(conn, :not_found, "")
    end
  end
  
  def signout(conn, _params) do
    conn
    |> configure_session(drop: true)
    |> redirect(to: "/")
  end
end
