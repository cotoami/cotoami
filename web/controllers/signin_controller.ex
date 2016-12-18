defmodule Cotoami.SigninController do
  use Cotoami.Web, :controller
  require Logger
  
  def request(conn, %{"email" => email}) do
    Logger.info "email: #{email}"
    json conn, "ok"
  end
  
  def signin(conn, %{"token" => token, "anonymous_id" => anonymous_id}) do
    
  end
end
