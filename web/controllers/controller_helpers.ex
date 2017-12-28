defmodule Cotoami.ControllerHelpers do
  @moduledoc """
  Utility functions for controllers.
  """

  import Plug.Conn, only: [send_resp: 3]
  alias Cotoami.{Amishi, Coto}

  def send_resp_by_constraint_error(conn, %Ecto.ConstraintError{} = e, content \\ nil)  do
    case e.constraint do
      "cotonomas_name_owner_id_index" ->
        send_resp(conn, :conflict, content || "")
      constraint ->
        send_resp(conn, :bad_request, content || constraint)
    end
  end

  defp payload_base(%Amishi{} = amishi, client_id) do
    %{
      clientId: client_id,
      amishi: Phoenix.View.render_one(amishi, Cotoami.AmishiView, "amishi.json")
    }
  end

  def broadcast_update(%Coto{} = coto, %Amishi{} = amishi, client_id) do
    Cotoami.Endpoint.broadcast(
      "global",
      "update",
      payload_base(amishi, client_id) 
      |> Map.put(:coto, Phoenix.View.render_one(coto, Cotoami.CotoView, "coto.json"))
    )
  end

  def broadcast_delete(coto_id, %Amishi{} = amishi, client_id) do
    Cotoami.Endpoint.broadcast(
      "global",
      "delete",
      payload_base(amishi, client_id) 
      |> Map.put(:cotoId, coto_id)
    )
  end

  def broadcast_post(%Coto{} = coto, cotonoma_key, %Amishi{} = amishi, client_id) do
    Cotoami.Endpoint.broadcast(
      "cotonomas:#{cotonoma_key}",
      "post",
      payload_base(amishi, client_id) 
      |> Map.put(:post, Phoenix.View.render_one(coto, Cotoami.CotoView, "coto.json"))
    )
  end
end
