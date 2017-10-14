defmodule Cotoami.ControllerHelpers do
  @moduledoc """
  Utility functions for controllers.
  """

  import Plug.Conn, only: [send_resp: 3]

  def send_resp_by_constraint_error(conn, %Ecto.ConstraintError{} = e)  do
    case e.constraint do
      "cotonomas_name_owner_id_index" ->
        send_resp(conn, :conflict, "")
      constraint ->
        send_resp(conn, :bad_request, constraint)
    end
  end

  def broadcast_post(coto, cotonoma_key, clientId) do
    Cotoami.Endpoint.broadcast(
      "cotonomas:#{cotonoma_key}",
      "post",
      %{
        post: Phoenix.View.render_one(coto, Cotoami.CotoView, "coto.json"),
        clientId: clientId
      }
    )
  end
end
