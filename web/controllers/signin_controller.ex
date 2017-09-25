defmodule Cotoami.SigninController do
  use Cotoami.Web, :controller
  require Logger
  alias Cotoami.{RedisService, AmishiService}

  def request(conn, %{"email" => email}) do
    token = RedisService.generate_signin_token(email)
    host_url = Cotoami.Router.Helpers.url(conn)
    email
    |> Cotoami.Email.signin_link(token, host_url)
    |> Cotoami.Mailer.deliver_now
    json conn, "ok"
  end

  def signin(conn, %{"token" => token}) do
    case RedisService.get_signin_email(token) do
      nil ->
        text conn, "Invalid token: #{token}"
      email ->
        amishi =
          case AmishiService.get_by_email(email) do
            nil -> AmishiService.create!(email)
            amishi -> amishi
          end
        conn
        |> Cotoami.Auth.start_session(amishi)
        |> redirect(to: "/")
        |> halt()
    end
  end
end
