defmodule Cotoami.ExternalUser do
  @moduledoc """
  A user managed by an external auth-provider.
  """

  defstruct auth_provider: "", auth_id: "", name: "", avatar_url: ""
end