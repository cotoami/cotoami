defmodule Cotoami.SigninController do
  use Cotoami.Web, :controller
  require Logger
  alias Cotoami.Repo
  alias Cotoami.Cotonoma
  alias Cotoami.RedisService
  alias Cotoami.AmishiService
  alias Cotoami.CotoService
  
  def request(conn, %{"email" => email, "save_anonymous" => save_anonymous}) do
    token = Cotoami.Auth.generate_signin_token
    anonymous_id = 
      if save_anonymous == "yes", 
        do: conn.assigns.anonymous_id, 
        else: "none"
    email
    |> Cotoami.Email.signin_link(token, anonymous_id)
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
        save_anonymous_cotos(anonymous_id, cotonoma.id, amishi.id)
        conn
        |> Cotoami.Auth.start_session(amishi)
        |> redirect(to: "/")
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
