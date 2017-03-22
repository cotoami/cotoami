defmodule Cotoami.CotonomaChannel do
  use Cotoami.Web, :channel
  
  def join("cotonomas:" <> cotonoma_key, _params, socket) do
    # TODO: check permission
    {:ok, socket}
  end
end
