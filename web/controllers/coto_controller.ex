defmodule Cotoami.CotoController do
  use Cotoami.Web, :controller
  require Logger
  alias Cotoami.RedisService
  
  def action(conn, _) do
    apply(__MODULE__, action_name(conn), [conn, conn.params, conn.assigns.anonymous_id])
  end
  
  def index(conn, _params, anonymous_id) do
    json conn, RedisService.get_cotos(anonymous_id)
  end

  def create(conn, %{"coto" => coto_params}, anonymous_id) do
    RedisService.add_coto(anonymous_id, coto_params)
    json conn, coto_params
  end
end
