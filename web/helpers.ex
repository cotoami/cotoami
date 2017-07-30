defmodule Cotoami.Helpers do
  @moduledoc """
  Global utility functions.
  """

  def drop_nil(map) when is_map(map) do
    map
    |> Enum.filter(fn {_, v} -> v != nil end)
    |> Enum.into(%{})
  end
end
