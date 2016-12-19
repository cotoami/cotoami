defmodule Cotoami.SigninController do
  use Cotoami.Web, :controller
  require Logger
  
  def request(conn, %{"email" => email}) do
    Logger.info "email: #{email}"
    
    email
    |> Cotoami.Email.signin_link
    |> Cotoami.Mailer.deliver_now
    
    json conn, "ok"
  end
  
  def signin(conn, %{"token" => token, "anonymous_id" => anonymous_id}) do
    json conn, "ok"
  end
end
