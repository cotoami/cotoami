defmodule Cotoami.Presence do
  use Phoenix.Presence, otp_app: :cotoami,
                        pubsub_server: Cotoami.PubSub
end
