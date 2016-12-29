defmodule Cotoami.SessionController do
  use Cotoami.Web, :controller
  require Logger
  alias Cotoami.AmishiService
  
  def index(conn, _params) do
    case conn.assigns do
      %{amishi: amishi} ->
        gravatar_profile = AmishiService.get_gravatar_profile(amishi.email)
        Logger.info "gravatar_profile: #{inspect gravatar_profile}"
        json conn, %{
          id: amishi.id,
          email: amishi.email,
          avatar_url: AmishiService.get_gravatar_url(amishi.email),
          display_name: Map.get(gravatar_profile, "displayName", amishi.email)
        }
      _ ->
        conn
        |> put_status(:not_found)
        |> json("No session")
    end
  end
  
  def signout(conn, _params) do
    conn
    |> configure_session(drop: true)
    |> redirect(to: "/")
  end
end
