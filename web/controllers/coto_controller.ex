defmodule Cotoami.CotoController do
  use Cotoami.Web, :controller
  require Logger
  alias Cotoami.{Repo, Coto, RedisService, CotoService, AmishiService}

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
        post_id = coto_params["postId"]

        {coto, posted_in} = CotoService.create!(cotonoma_id, amishi.id, content)

        if posted_in do
          %{coto |
            :posted_in => posted_in,
            :amishi => AmishiService.append_gravatar_profile(amishi)
          } |> broadcast_post(posted_in.key, clientId)
        end

        render(conn, "created.json", coto: coto, postId: post_id)

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
        |> ensure_not_to_be_cotonoma()
        |> Repo.delete!()
        send_resp(conn, :no_content, "")
      _ ->
        send_resp(conn, :no_content, "")
    end
  end

  defp ensure_not_to_be_cotonoma(coto) do
    if coto.as_cotonoma,
      do: raise Cotoami.Exceptions.UnsupportedOperation,
      else: coto
  end
end
