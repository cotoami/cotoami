defmodule Cotoami.AmishiController do
  use Cotoami.Web, :controller
  require Logger
  alias Cotoami.{AmishiService, RedisService, AmishiView}

  def action(conn, _) do
    apply(__MODULE__, action_name(conn), [conn, conn.params, conn.assigns.amishi])
  end

  def show_by_email(conn, %{"email" => email}, _amishi) do
    case AmishiService.get_by_email(email) do
      nil ->
        send_resp(conn, :not_found, "")
      amishi ->
        render(conn, "amishi.json", amishi: amishi)
    end
  end

  def invite(conn, %{"email" => email}, amishi) do
    case AmishiService.get_by_email(email) do
      nil ->
        token = RedisService.generate_invite_token(email)
        host_url = Cotoami.Router.Helpers.url(conn)
        email
        |> Cotoami.Email.invitation(token, host_url, amishi)
        |> Cotoami.Mailer.deliver_now
        json conn, "ok"
      invitee ->
        conn
        |> put_status(:conflict)
        |> json(Phoenix.View.render_one(invitee, AmishiView, "amishi.json"))
    end
  end
end
