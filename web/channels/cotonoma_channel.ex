defmodule Cotoami.CotonomaChannel do
  use Cotoami.Web, :channel
  alias Cotoami.CotonomaService
  
  def join("cotonomas:" <> cotonoma_key, _params, socket) do
    amishi_id = socket.assigns.amishi.id
    case CotonomaService.get_by_key(cotonoma_key, amishi_id) do
      nil ->
        {:error, %{reason: "unauthorized"}}
      cotonoma ->
        {:ok, socket}
    end
  end
end
