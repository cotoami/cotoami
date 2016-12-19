defmodule Cotoami.CotoController do
  use Cotoami.Web, :controller
  require Logger
  alias Cotoami.RedisService
    
  def index(conn, _params) do
    case conn.assigns do
      %{amishi: amishi} ->
        json conn, []
      _ ->
        json conn, RedisService.get_cotos(conn.assigns.anonymous_id)
    end
  end

  def create(conn, %{"coto" => coto_params}) do
    case conn.assigns do
      %{amishi: amishi} ->
        json conn, coto_params
      _ ->
        RedisService.add_coto(conn.assigns.anonymous_id, coto_params)
        json conn, coto_params
    end
  end
end
