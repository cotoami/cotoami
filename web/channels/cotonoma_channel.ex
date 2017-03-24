defmodule Cotoami.CotonomaChannel do
  use Cotoami.Web, :channel
  alias Cotoami.Presence
  alias Cotoami.CotonomaService
  
  def join("cotonomas:" <> cotonoma_key, _params, socket) do
    amishi_id = socket.assigns.amishi.id
    case CotonomaService.get_by_key(cotonoma_key, amishi_id) do
      nil ->
        {:error, %{reason: "unauthorized"}}
      _cotonoma ->
        send(self, :after_join)
        {:ok, socket}
    end
  end
  
  def handle_info(:after_join, socket) do
    push socket, "presence_state", Presence.list(socket)
    {:ok, _} = Presence.track(socket, socket.assigns.amishi.id, %{
      online_at: :os.system_time(:milli_seconds)
    })
    {:noreply, socket}
  end
end
