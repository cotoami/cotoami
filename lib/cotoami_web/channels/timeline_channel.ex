defmodule CotoamiWeb.TimelineChannel do
  @moduledoc """
  Realtime communication in a cotonoma.
  """

  use CotoamiWeb, :channel
  alias Cotoami.Cotonoma
  alias Cotoami.CotonomaService
  alias CotoamiWeb.Presence

  def join("timelines:" <> cotonoma_key, _params, socket) do
    case CotonomaService.get_by_key(cotonoma_key) do
      nil ->
        {:error, %{reason: "not-found"}}

      cotonoma ->
        if Cotonoma.accessible_by?(cotonoma, socket.assigns.amishi) do
          send(self(), :after_join)
          {:ok, socket}
        else
          {:error, %{reason: "no-permission"}}
        end
    end
  end

  def handle_info(:after_join, socket) do
    push(socket, "presence_state", Presence.list(socket))

    {:ok, _} =
      Presence.track(socket, socket.assigns.amishi.id, %{
        online_at: :os.system_time(:milli_seconds)
      })

    {:noreply, socket}
  end
end
