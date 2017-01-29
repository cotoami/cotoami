defmodule Cotoami.CotoController do
  use Cotoami.Web, :controller
  require Logger
  alias Cotoami.Repo
  alias Cotoami.Coto
  alias Cotoami.RedisService
  alias Cotoami.CotoService
    
  def index(conn, _params) do
    case conn.assigns do
      %{amishi: amishi} ->
        cotos = Coto |> Coto.for_amishi(amishi.id) |> Repo.all
        render(conn, "index.json", %{rows: cotos})
      _ ->
        json conn, RedisService.get_cotos(conn.assigns.anonymous_id)
    end
  end

  def create(conn, %{"coto" => coto_params}) do
    case conn.assigns do
      %{amishi: amishi} ->
        coto = CotoService.create!(nil, amishi.id, coto_params["content"])
        render(conn, "created.json", coto: coto, postId: coto_params["postId"])
      _ ->
        RedisService.add_coto(conn.assigns.anonymous_id, coto_params)
        json conn, coto_params
    end
  end
  
  def delete(conn, %{"id" => id}) do
    case conn.assigns do
      %{amishi: amishi} ->
        Coto
        |> Coto.for_amishi(amishi.id)
        |> Repo.get!(id)
        |> Repo.delete!()
        send_resp(conn, :no_content, "")
      _ ->
        send_resp(conn, :no_content, "")
    end
  end
end
