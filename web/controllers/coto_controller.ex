defmodule Cotoami.CotoController do
  use Cotoami.Web, :controller
  require Logger
  
  def action(conn, _) do
    apply(__MODULE__, action_name(conn), [conn, conn.params, conn.assigns.anonymous_id])
  end
  
  def index(conn, _params, anonymous_id) do
    json conn, %{cotos: []}
  end

  def create(conn, %{"coto" => coto_params}, anonymous_id) do
    Logger.info "coto: #{inspect coto_params}"
    json conn, %{coto: coto_params}
  end
end
