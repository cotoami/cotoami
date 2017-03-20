defmodule Cotoami.CotoController do
  use Cotoami.Web, :controller
  require Logger
  alias Cotoami.Repo
  alias Cotoami.Coto
  alias Cotoami.RedisService
  alias Cotoami.CotoService
  alias Cotoami.AmishiService
  
  plug :scrub_params, "coto" when action in [:create]
    
  def index(conn, _params) do
    case conn.assigns do
      %{amishi: amishi} ->
        cotos = CotoService.get_cotos_by_amishi(amishi.id)
        render(conn, "index.json", %{rows: cotos})
      _ ->
        json conn, RedisService.get_cotos(conn.assigns.anonymous_id)
    end
  end

  def create(conn, %{"clientId" => clientId, "coto" => coto_params}) do
    case conn.assigns do
      %{amishi: amishi} ->
        cotonoma_id = coto_params["cotonoma_id"]
        content = coto_params["content"]
        postId = coto_params["postId"]
        
        {coto, cotonoma} = CotoService.create!(cotonoma_id, amishi.id, content)
        
        %{coto | 
          :posted_in => cotonoma,
          :amishi => AmishiService.append_gravatar_profile(amishi)
        } |> broadcast_post(cotonoma.key, clientId)
        
        render(conn, "created.json", coto: coto, postId: postId)
        
      _ ->
        RedisService.add_coto(conn.assigns.anonymous_id, coto_params)
        json conn, coto_params
    end
  end
  
  defp broadcast_post(coto, cotonoma_key, clientId) do
    Cotoami.Endpoint.broadcast(
      "cotonomas:#{cotonoma_key}", 
      "post",
      %{
        post: Phoenix.View.render_one(coto, Cotoami.CotoView, "coto.json"),
        clientId: clientId
      }
    )
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
