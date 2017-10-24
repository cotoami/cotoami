defmodule Cotoami.RedisServiceTest do
  use ExUnit.Case
  alias Cotoami.RedisService

  describe "when two gravatar profiles are stored in redis" do
    setup do
      RedisService.put_gravatar_profile("foo@example.com", "hello")
      RedisService.put_gravatar_profile("bar@example.com", "bye")
      :ok
    end

    test "they can be gotten one by one" do
      assert RedisService.get_gravatar_profile("foo@example.com") == "hello"
      assert RedisService.get_gravatar_profile("bar@example.com") == "bye"
    end

    test "they can be gotten at once" do
      assert RedisService.get_gravatar_profiles(
        ["foo@example.com", "bar@example.com"]) ==
          %{"foo@example.com" => "hello", "bar@example.com" => "bye"}
    end
  end
end
