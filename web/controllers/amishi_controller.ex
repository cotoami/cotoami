defmodule Cotoami.AmishiController do
  use Cotoami.Web, :controller
  require Logger
  alias Bolt.Sips
  alias Cotoami.{
    AmishiService, CotoService, CotoGraphService,
    CotoView, AmishiView
  }

  def show_by_email(conn, %{"email" => email}) do
    case AmishiService.get_by_email(email) do
      nil ->
        send_resp(conn, :not_found, "")
      amishi ->
        render(conn, "amishi.json",
          amishi: AmishiService.append_gravatar_profile(amishi)
        )
    end
  end

  def export(conn, _params) do
    case conn.assigns do
      %{amishi: amishi} ->
        data = %{
          amishi:
            Phoenix.View.render_one(amishi, AmishiView, "amishi.json"),
          cotos:
            CotoService.export_by_amishi(amishi)
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

      _ ->
        send_resp(conn, :unauthorized, "")
    end
  end
end
