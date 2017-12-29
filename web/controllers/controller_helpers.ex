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

  defp broadcast(value, key, topic, event, %Amishi{} = amishi, client_id) do
    Cotoami.Endpoint.broadcast(
      topic, event, payload_base(amishi, client_id) |> Map.put(key, value))
  end

  def broadcast_update(%Coto{} = coto, %Amishi{} = amishi, client_id) do
    coto
    |> Phoenix.View.render_one(Cotoami.CotoView, "coto.json")
    |> broadcast(:coto, "global", "update", amishi, client_id)
  end

  def broadcast_delete(coto_id, %Amishi{} = amishi, client_id) do
    coto_id
    |> broadcast(:cotoId, "global", "delete", amishi, client_id)
  end

  def broadcast_post(%Coto{} = coto, cotonoma_key, %Amishi{} = amishi, client_id) do
    coto
    |> Phoenix.View.render_one(Cotoami.CotoView, "coto.json")
    |> broadcast(:post, "cotonomas:#{cotonoma_key}", "post", amishi, client_id)
  end

  def broadcast_pin(coto_id, cotonoma_key, %Amishi{} = amishi, client_id) do
    coto_id
    |> broadcast(:cotoId, "cotonomas:#{cotonoma_key}", "pin", amishi, client_id)
  end
end
