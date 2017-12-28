defmodule Cotoami.ControllerHelpers do
  @moduledoc """
  Utility functions for controllers.
  """

  import Plug.Conn, only: [send_resp: 3]

  def send_resp_by_constraint_error(conn, %Ecto.ConstraintError{} = e, content \\ nil)  do
    case e.constraint do
      "cotonomas_name_owner_id_index" ->
        send_resp(conn, :conflict, content || "")
      constraint ->
        send_resp(conn, :bad_request, content || constraint)
    end
  end

  def broadcast_update(coto, client_id) do
    Cotoami.Endpoint.broadcast(
      "global",
      "update",
      %{
        clientId: client_id,
        coto: Phoenix.View.render_one(coto, Cotoami.CotoView, "coto.json")
      }
    )
  end

  def broadcast_delete(coto_id, client_id) do
    Cotoami.Endpoint.broadcast(
      "global",
      "delete",
      %{
        clientId: client_id,
        cotoId: coto_id
      }
    )
  end

  def broadcast_post(coto, cotonoma_key, client_id) do
    Cotoami.Endpoint.broadcast(
      "cotonomas:#{cotonoma_key}",
      "post",
      %{
        clientId: client_id, 
        post: Phoenix.View.render_one(coto, Cotoami.CotoView, "coto.json")
      }
    )
  end
end
