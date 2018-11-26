defmodule CotoamiWeb.CotonomaChannel do
  @moduledoc """
  Realtime update of a cotonoma.
  """

  use CotoamiWeb, :channel
  alias Cotoami.Cotonoma
  alias Cotoami.CotonomaService

  def join("cotonomas:" <> cotonoma_key, _params, socket) do
    case CotonomaService.get_by_key(cotonoma_key) do
      nil ->
        {:error, %{reason: "not-found"}}

      cotonoma ->
        if Cotonoma.accessible_by?(cotonoma, socket.assigns.amishi) do
          {:ok, socket}
        else
          {:error, %{reason: "no-permission"}}
        end
    end
  end
end
