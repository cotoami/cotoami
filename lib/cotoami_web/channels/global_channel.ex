defmodule CotoamiWeb.GlobalChannel do
  @moduledoc """
  Global realtime events
  """

  use CotoamiWeb, :channel

  def join("global", _params, socket) do
    {:ok, socket}
  end
end
