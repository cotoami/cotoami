defmodule CotoamiWeb.CotoChannel do
  @moduledoc """
  Realtime update of a coto.
  """

  use CotoamiWeb, :channel

  def join("cotos:" <> _coto_id, _params, socket) do
    {:ok, socket}
  end
end
