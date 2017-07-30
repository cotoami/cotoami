defmodule Cotoami.ControllerHelpers do
  @moduledoc """
  Utility functions for controllers.
  """

  def broadcast_post(coto, cotonoma_key, clientId) do
    Cotoami.Endpoint.broadcast(
      "cotonomas:#{cotonoma_key}",
      "post",
      %{
        post: Phoenix.View.render_one(coto, Cotoami.CotoView, "coto.json"),
        clientId: clientId
      }
    )
  end
end
