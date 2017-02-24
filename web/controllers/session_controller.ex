defmodule Cotoami.SessionController do
  use Cotoami.Web, :controller
  require Logger
  alias Cotoami.AmishiService
  alias Cotoami.AmishiView
  
  def index(conn, _params) do
    case conn.assigns do
      %{amishi: amishi} ->
        render(conn, AmishiView, "amishi.json", 
          amishi: AmishiService.append_gravatar_profile(amishi)
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
