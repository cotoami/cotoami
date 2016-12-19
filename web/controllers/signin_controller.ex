defmodule Cotoami.SigninController do
  use Cotoami.Web, :controller
  require Logger
  
  def request(conn, %{"email" => email}) do
    token = Cotoami.Auth.generate_signin_token
    email
    |> Cotoami.Email.signin_link(token, conn.assigns.anonymous_id)
    |> Cotoami.Mailer.deliver_now
    Cotoami.RedisService.put_signin_token(token, email)
    json conn, "ok"
  end
  
  def signin(conn, %{"token" => token, "anonymous_id" => anonymous_id}) do
    json conn, "ok"
  end
end
