defmodule CotoamiWeb.ControllerHelpers do
  @moduledoc """
  Utility functions for controllers.
  """

  import Plug.Conn, only: [send_resp: 3]
  alias Cotoami.{Amishi, Coto, Cotonoma}

  def send_resp_by_constraint_error(conn, %Ecto.ConstraintError{} = e, content \\ nil) do
    case e.constraint do
      "cotonomas_name_owner_id_index" ->
        send_resp(conn, :conflict, content || "")

      constraint ->
        send_resp(conn, :bad_request, content || constraint)
    end
  end

  def get_flags_in_params(params, keys) do
    Enum.map(keys, fn key ->
      {String.to_atom(key), Map.has_key?(params, key)}
    end)
  end

  defp payload_base(%Amishi{} = amishi, client_id) do
    %{
      clientId: client_id,
      amishi: Phoenix.View.render_one(amishi, CotoamiWeb.AmishiView, "amishi.json")
    }
  end

  defp broadcast(body, topic, event, %Amishi{} = amishi, client_id) do
    CotoamiWeb.Endpoint.broadcast(
      topic,
      event,
      payload_base(amishi, client_id) |> Map.put(:body, body)
    )
  end

  #
  # Channel: 'cotonomas:*'
  #

  def broadcast_cotonoma_update(%Cotonoma{key: key} = cotonoma, %Amishi{} = amishi, client_id) do
    cotonoma
    |> Phoenix.View.render_one(CotoamiWeb.CotonomaView, "cotonoma.json")
    |> broadcast("cotonomas:#{key}", "update", amishi, client_id)
  end

  #
  # Channel: 'timelines:*'
  #

  def broadcast_post(%Coto{} = coto, cotonoma_key, %Amishi{} = amishi, client_id) do
    coto
    |> Phoenix.View.render_one(CotoamiWeb.CotoView, "coto.json")
    |> broadcast("timelines:#{cotonoma_key}", "post", amishi, client_id)
  end

  #
  # Channel: 'coto:*'
  #

  def broadcast_delete(coto_id, %Amishi{} = amishi, client_id) do
    coto_id
    |> broadcast("cotos:#{coto_id}", "delete", amishi, client_id)
  end

  def broadcast_coto_update(%Coto{} = coto, %Amishi{} = amishi, client_id) do
    coto
    |> Phoenix.View.render_one(CotoamiWeb.CotoView, "coto.json")
    |> broadcast("cotos:#{coto.id}", "update", amishi, client_id)
  end

  def broadcast_cotonomatize(%Cotonoma{} = cotonoma, %Amishi{} = amishi, client_id) do
    cotonoma
    |> Phoenix.View.render_one(CotoamiWeb.CotonomaView, "cotonoma.json")
    |> broadcast("cotos:#{cotonoma.coto_id}", "cotonomatize", amishi, client_id)
  end

  def broadcast_connect(
        %Coto{} = start_coto,
        %Coto{} = end_coto,
        linking_phrase,
        %Amishi{} = amishi,
        client_id
      ) do
    %{
      start: Phoenix.View.render_one(start_coto, CotoamiWeb.CotoView, "coto.json"),
      end: Phoenix.View.render_one(end_coto, CotoamiWeb.CotoView, "coto.json"),
      linking_phrase: linking_phrase
    }
    |> broadcast("cotos:#{start_coto.id}", "connect", amishi, client_id)
  end

  def broadcast_disconnect(start_id, end_id, %Amishi{} = amishi, client_id) do
    %{start_id: start_id, end_id: end_id}
    |> broadcast("cotos:#{start_id}", "disconnect", amishi, client_id)
  end

  def broadcast_connection_update(start_id, end_id, linking_phrase, %Amishi{} = amishi, client_id) do
    %{start_id: start_id, end_id: end_id, linking_phrase: linking_phrase}
    |> broadcast("cotos:#{start_id}", "connection_update", amishi, client_id)
  end

  def broadcast_reorder(start_id, end_ids, %Amishi{} = amishi, client_id) do
    %{start_id: start_id, end_ids: end_ids}
    |> broadcast("cotos:#{start_id}", "reorder", amishi, client_id)
  end
end
