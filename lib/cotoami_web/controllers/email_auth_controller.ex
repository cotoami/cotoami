defmodule CotoamiWeb.EmailAuthController do
  use CotoamiWeb, :controller
  require Logger
  alias Cotoami.{RedisService, AmishiService}

  def signup_enabled do
    :cotoami
    |> Application.get_env(__MODULE__, [])
    |> Keyword.get(:signup_enabled)
  end

  def is_allowed_to_signin?(email) do
    signup_enabled() 
      || email in AmishiService.owner_emails() 
      || AmishiService.get_by_email(email)
  end

  def request(conn, %{"email" => email}) do
    if is_allowed_to_signin?(email) do
      token = RedisService.generate_signin_token(email)
      host_url = CotoamiWeb.Router.Helpers.url(conn)
      email
      |> CotoamiWeb.Email.signin_link(token, host_url)
      |> Cotoami.Mailer.deliver_now
      json conn, "ok"
    else
      send_resp(conn, :unauthorized, "")
    end
  end

  def signin(conn, %{"token" => token}) do
    case RedisService.get_signin_email(token) do
      nil ->
        text conn, "The signin token has been expired."
      email ->
        amishi = AmishiService.insert_or_update_by_email!(email)
        start_session_and_redirect_to_home(conn, amishi)
    end
  end

  def accept_invite(conn, %{"token" => token}) do
    case RedisService.get_invite(token) do
      nil ->
        text conn, "The invitation is not found or has been expired."
      {invitee_email, inviter_id} ->
        case AmishiService.get(inviter_id) do
          nil ->
            text conn, "The inviter is not found."
          inviter ->
            amishi = AmishiService.accept_invite!(invitee_email, inviter)
            start_session_and_redirect_to_home(conn, amishi)
        end
    end
  end

  defp start_session_and_redirect_to_home(conn, amishi) do
    conn
    |> CotoamiWeb.AuthPlug.start_session(amishi)
    |> redirect(to: "/")
    |> halt()
  end
end
