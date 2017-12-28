defmodule Cotoami.GlobalChannel do
  @moduledoc """
  Global realtime events
  """

  use Cotoami.Web, :channel

  def join("global", _params, socket) do
    send(self(), :after_join)
    {:ok, socket}
  end
end
