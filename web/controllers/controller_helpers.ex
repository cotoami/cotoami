defmodule Cotoami.ControllerHelpers do
  @moduledoc """
  Utility functions for controllers.
  """

  import Plug.Conn, only: [send_resp: 3]
  alias Cotoami.{Amishi, Coto, Cotonoma}

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

  defp broadcast(body, topic, event, %Amishi{} = amishi, client_id) do
    Cotoami.Endpoint.broadcast(
      topic, event, payload_base(amishi, client_id) |> Map.put(:body, body))
  end

  #
  # Channel: 'global'
  #

  def broadcast_update(%Coto{} = coto, %Amishi{} = amishi, client_id) do
    coto
    |> Phoenix.View.render_one(Cotoami.CotoView, "coto.json")
    |> broadcast("global", "update", amishi, client_id)
  end

  def broadcast_delete(coto_id, %Amishi{} = amishi, client_id) do
    coto_id
    |> broadcast("global", "delete", amishi, client_id)
  end

  def broadcast_cotonomatize(%Cotonoma{} = cotonoma, %Amishi{} = amishi, client_id) do
    cotonoma
    |> Phoenix.View.render_one(Cotoami.CotonomaView, "cotonoma.json")
    |> broadcast("global", "cotonomatize", amishi, client_id)
  end

  def broadcast_cotonoma(%Cotonoma{} = cotonoma, %Amishi{} = amishi, client_id) do
    cotonoma
    |> Phoenix.View.render_one(Cotoami.CotonomaView, "cotonoma.json")
    |> broadcast("global", "cotonoma", amishi, client_id)
  end

  def broadcast_connect(%Coto{} = start_coto, %Coto{} = end_coto, %Amishi{} = amishi, client_id) do
    %{
      start: Phoenix.View.render_one(start_coto, Cotoami.CotoView, "coto.json"), 
      end: Phoenix.View.render_one(end_coto, Cotoami.CotoView, "coto.json")
    }
    |> broadcast("global", "connect", amishi, client_id)
  end

  #
  # Channel: 'cotonomas:*'
  #

  def broadcast_post(%Coto{} = coto, cotonoma_key, %Amishi{} = amishi, client_id) do
    coto
    |> Phoenix.View.render_one(Cotoami.CotoView, "coto.json")
    |> broadcast("cotonomas:#{cotonoma_key}", "post", amishi, client_id)
  end

  def broadcast_pin(coto_id, cotonoma_key, %Amishi{} = amishi, client_id) do
    coto_id
    |> broadcast("cotonomas:#{cotonoma_key}", "pin", amishi, client_id)
  end

  def broadcast_unpin(coto_id, cotonoma_key, %Amishi{} = amishi, client_id) do
    coto_id
    |> broadcast("cotonomas:#{cotonoma_key}", "unpin", amishi, client_id)
  end
end
