defmodule Cotoami.AmishiController do
  use Cotoami.Web, :controller
  require Logger
  alias Bolt.Sips
  alias Cotoami.{
    AmishiService, CotoService, CotoGraphService, RedisService,
    CotoView, AmishiView
  }

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

  def export(conn, _params, amishi) do
    data = %{
      amishi:
        Phoenix.View.render_one(amishi, AmishiView, "amishi.json"),
      cotos:
        amishi
        |> CotoService.export_by_amishi()
        |> Phoenix.View.render_many(CotoView, "coto.json"),
      connections:
        CotoGraphService.export_connections_by_amishi(Sips.conn, amishi)
    }

    conn
    |> put_resp_content_type("application/octet-stream", nil)
    |> put_resp_header(
      "content-disposition",
      ~s[attachment; filename="cotoami-export.json"])
    |> send_resp(200, Poison.encode!(data, pretty: true))
  end

  def import(conn, %{"data" => data}, amishi) do
    case Poison.decode(data) do
      {:ok, json_data} ->
        json conn, %{cotos: 1, connections: 2}
      {:error, %{message: message}} ->
        conn
        |> put_status(:bad_request)
        |> json(message)
    end
  end
end
