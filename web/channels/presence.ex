defmodule Cotoami.Presence do
  @moduledoc """
  Provides Presence tracking to processes and channels.
  """

  use Phoenix.Presence, otp_app: :cotoami,
                        pubsub_server: Cotoami.PubSub
end
