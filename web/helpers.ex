defmodule Cotoami.Helpers do
  @moduledoc """
  Global utility functions.
  """

  def drop_nil(map) when is_map(map) do
    map
    |> Enum.filter(fn {_, v} -> v != nil end)
    |> Enum.into(%{})
  end

  # old export data uses microseconds unixtime
  def unixtime_to_datetime!(unixtime) do
    case DateTime.from_unix(unixtime, :microsecond) do
      {:ok, datetime} -> datetime
      {:error, _} -> DateTime.from_unix!(unixtime, :microsecond)
    end
  end
end
