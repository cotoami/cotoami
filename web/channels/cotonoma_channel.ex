defmodule Cotoami.CotonomaChannel do
  use Cotoami.Web, :channel
  alias Cotoami.CotonomaService
  alias Cotoami.RedisService
  
  def join("cotonomas:" <> cotonoma_key, _params, socket) do
    case CotonomaService.get_by_key(cotonoma_key, amishi_id) do
      nil ->
        {:error, %{reason: "unauthorized"}}
      cotonoma ->
        amishi_id = socket.assigns.amishi.id
        RedisService.join_cotonoma(cotonoma.id, amishi_id)
        {:ok, socket}
    end
  end
end
