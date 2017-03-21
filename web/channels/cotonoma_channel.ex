defmodule Cotoami.CotonomaChannel do
  use Cotoami.Web, :channel
  
  def join("cotonomas:" <> cotonoma_key, _params, socket) do
    {:ok, socket}
  end
end
