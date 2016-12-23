defmodule Cotoami.SigninController do
  use Cotoami.Web, :controller
  require Logger
  alias Cotoami.RedisService
  alias Cotoami.AmishiService
  alias Cotoami.CotoService
  alias Cotoami.CotonomaService
  
  def request(conn, %{"email" => email, "save_anonymous" => save_anonymous}) do
    token = Cotoami.Auth.generate_signin_token
    anonymous_id = 
      if save_anonymous == "yes", 
        do: conn.assigns.anonymous_id, 
        else: "none"
    host_url = Cotoami.Router.Helpers.url(conn)
    email
    |> Cotoami.Email.signin_link(token, anonymous_id, host_url)
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
              {amishi, CotonomaService.get_or_create_home!(amishi.id)}
          end
        save_anonymous_cotos(anonymous_id, cotonoma.id, amishi.id)
        conn
        |> Cotoami.Auth.start_session(amishi)
        |> redirect(to: "/")
        |> halt()
    end
  end
  
  defp save_anonymous_cotos(anonymous_id, cotonoma_id, amishi_id) do
    RedisService.get_cotos(anonymous_id)
    |> Enum.each(fn(coto) ->
      content = Map.get(coto, "content")
      CotoService.create!(cotonoma_id, amishi_id, content)
    end)
    RedisService.clear_cotos(anonymous_id)
  end
end
