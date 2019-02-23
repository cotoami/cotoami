defmodule CotoamiWeb.AmishiController do
  use CotoamiWeb, :controller
  require Logger
  alias Cotoami.{Amishi, AmishiService, RedisService}
  alias CotoamiWeb.AmishiView

  def action(conn, _) do
    apply(__MODULE__, action_name(conn), [conn, conn.params, conn.assigns.amishi])
  end

  def show(conn, %{"id" => id}, _amishi) do
    AmishiService.get(id) |> render_amishi(conn)
  end

  def show_by_email(conn, %{"email" => email}, _amishi) do
    AmishiService.get_by_email(email) |> render_amishi(conn)
  end

  defp render_amishi(amishi, conn) do
    case amishi do
      nil ->
        send_resp(conn, :not_found, "")

      amishi ->
        render(conn, "amishi.json", amishi: amishi)
    end
  end

  def invite(conn, %{"email" => email}, amishi) do
    if AmishiService.can_invite_someone?(amishi) do
      case AmishiService.get_by_email(email) do
        nil ->
          token = RedisService.generate_invite_token(email, amishi)
          host_url = CotoamiWeb.Router.Helpers.url(conn)

          email
          |> CotoamiWeb.Email.invitation(token, host_url, amishi)
          |> Cotoami.Mailer.deliver_now()

          json(conn, "ok")

        invitee ->
          conn
          |> put_status(:conflict)
          |> json(Phoenix.View.render_one(invitee, AmishiView, "amishi.json"))
      end
    else
      send_resp(conn, :unauthorized, "Invite limit exceeded")
    end
  end

  def invitees(conn, _params, amishi) do
    amishis = AmishiService.invitees(amishi)
    render(conn, "amishis.json", %{amishis: amishis})
  end

  def refresh_email_user_data(conn, _params, %{owner: true}) do
    email_users =
      Amishi
      |> Repo.all()
      |> Enum.map(& &1.email)
      |> Enum.reject(&is_nil/1)
      |> Enum.map(&AmishiService.insert_or_update_by_email!/1)

    text(conn, "#{length(email_users)} records updated.")
  end
end
