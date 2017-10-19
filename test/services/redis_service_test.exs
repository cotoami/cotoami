defmodule Cotoami.RedisServiceTest do
  use ExUnit.Case
  alias Cotoami.RedisService

  describe "two gravatar profiles in redis" do
    setup do
      RedisService.put_gravatar_profile("foo@example.com", "hello")
      RedisService.put_gravatar_profile("bar@example.com", "bye")
      :ok
    end

    test "can be gotten one by one" do
      assert RedisService.get_gravatar_profile("foo@example.com") == "hello"
      assert RedisService.get_gravatar_profile("bar@example.com") == "bye"
    end

    test "batch get a gravatar profiles" do
      assert RedisService.get_gravatar_profiles(
        ["foo@example.com", "bar@example.com"]) == ["hello", "bye"]
    end
  end
end
