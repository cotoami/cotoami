defmodule Cotoami.SigninController do
  use Cotoami.Web, :controller
  require Logger
  alias Cotoami.Repo
  alias Cotoami.Cotonoma
  alias Cotoami.RedisService
  alias Cotoami.AmishiService
  
  def request(conn, %{"email" => email}) do
    token = Cotoami.Auth.generate_signin_token
    email
    |> Cotoami.Email.signin_link(token, conn.assigns.anonymous_id)
    |> Cotoami.Mailer.deliver_now
    RedisService.put_signin_token(token, email)
    json conn, "ok"
  end
  
  def signin(conn, %{"token" => token, "anonymous_id" => anonymous_id}) do
    case RedisService.get_signin_email(token) do
      nil ->
        text conn, "Invalid token"
      email ->
        {amishi, cotonoma} = 
          case AmishiService.get_by_email(email) do
            nil -> 
              AmishiService.create!(email)
            amishi -> 
              {amishi, Cotonoma.query_home(amishi.id) |> Repo.one!}
          end
        Logger.info "Home cotonoma: #{inspect cotonoma}"
        conn
        |> Cotoami.Auth.start_session(amishi)
        |> redirect(to: "/")
    end
  end
end
