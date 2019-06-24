defmodule CotoamiWeb.CotonomaChannel do
  @moduledoc """
  Realtime update of a cotonoma.
  """

  use CotoamiWeb, :channel
  alias Cotoami.CotonomaService

  def join("cotonomas:" <> cotonoma_key, _params, socket) do
    CotonomaService.get_by_key!(cotonoma_key, socket.assigns.amishi)
    {:ok, socket}
  rescue
    _ in Cotoami.Exceptions.NotFound -> {:error, %{reason: "not-found"}}
    _ in Cotoami.Exceptions.NoPermission -> {:error, %{reason: "no-permission"}}
  end
end
