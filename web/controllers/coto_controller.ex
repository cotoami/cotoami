defmodule Cotoami.CotoController do
  use Cotoami.Web, :controller
  require Logger
  alias Cotoami.{CotoService}

  plug :scrub_params, "coto" when action in [:create, :update]

  def action(conn, _) do
    apply(__MODULE__, action_name(conn), [conn, conn.params, conn.assigns.amishi])
  end

  def index(conn, _params, amishi) do
    cotos = CotoService.get_cotos_by_amishi(amishi)
    render(conn, "index.json", %{rows: cotos})
  end

  def create(conn, %{"clientId" => clientId, "coto" => coto_params}, amishi) do
    cotonoma_id = coto_params["cotonoma_id"]
    content = coto_params["content"]
    post_id = coto_params["postId"]

    {coto, posted_in} = CotoService.create!(cotonoma_id, amishi.id, content)

    if posted_in do
      %{coto | posted_in: posted_in, amishi: amishi}
      |> broadcast_post(posted_in.key, clientId)
    end

    render(conn, "created.json", coto: coto, postId: post_id)
  end

  def update(conn, %{"id" => id, "coto" => coto_params}, amishi) do
    case CotoService.update_content(id, coto_params, amishi) do
      {:ok, coto} -> render(conn, "coto.json", coto: coto)
      {:error, _} -> send_resp(conn, :internal_server_error, "")
    end
  end

  def delete(conn, %{"id" => id}, amishi) do
    CotoService.delete(id, amishi)
    send_resp(conn, :no_content, "")
  end
end
