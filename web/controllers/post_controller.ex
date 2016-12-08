defmodule Cotoami.PostController do
  use Cotoami.Web, :controller
  require Logger
  
  def action(conn, _) do
    apply(__MODULE__, action_name(conn), [conn, conn.params, conn.assigns.anonymous_id])
  end
  
  def index(conn, _params, anonymous_id) do
    json conn, %{posts: []}
  end

  def create(conn, %{"post" => post_params}, anonymous_id) do
    Logger.info "post: #{inspect post_params}"
    json conn, %{post: post_params}
  end
end
