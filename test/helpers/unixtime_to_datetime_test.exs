defmodule Cotoami.UnixtimeToDatetimeTest do
  use ExUnit.Case
  alias Cotoami.Helpers

  test "microseconds" do
    datetime = Helpers.unixtime_to_datetime!(1499865016802860)
    assert DateTime.to_iso8601(datetime) == "2017-07-12T13:10:16.802860Z"
  end

  test "milliseconds" do
    datetime = Helpers.unixtime_to_datetime!(1507551526680)
    assert DateTime.to_iso8601(datetime) == "2017-10-09T12:18:46.680Z"
  end
end
