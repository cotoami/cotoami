defmodule Cotoami.CotoController do
  use Cotoami.Web, :controller
  require Logger
  alias Cotoami.Repo
  alias Cotoami.Coto
  alias Cotoami.Cotonoma
  alias Cotoami.RedisService
  alias Cotoami.CotoService
    
  def index(conn, _params) do
    case conn.assigns do
      %{amishi: amishi} ->
        cotonoma = home!(amishi.id)
        cotos = Coto.in_cotonoma(cotonoma.id) |> Repo.all
        render(conn, "index.json", %{rows: cotos})
      _ ->
        json conn, RedisService.get_cotos(conn.assigns.anonymous_id)
    end
  end

  def create(conn, %{"coto" => coto_params}) do
    case conn.assigns do
      %{amishi: amishi} ->
        cotonoma = home!(amishi.id)
        coto = CotoService.create!(cotonoma.id, amishi.id, coto_params["content"])
        render(conn, "created.json", coto: coto, postId: coto_params["postId"])
      _ ->
        RedisService.add_coto(conn.assigns.anonymous_id, coto_params)
        json conn, coto_params
    end
  end
  
  defp home!(amishi_id), do: Cotonoma.query_home(amishi_id) |> Repo.one!
end
