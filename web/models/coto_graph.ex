defmodule Cotoami.CotoGraph do
  @moduledoc """
  CotoGraph contains cotos (nodes) and connections (relationships) between them.
  """

  defstruct cotos: %{}, root_connections: [], connections: %{}
end
