defmodule Cotoami.RedisService do
  @moduledoc """
  Provides Redis related functions.
  """

  require Logger

  #
  # Sign-in keys
  #

  # @signin_key_expire_seconds 60 * 10
  @signin_key_expire_seconds 60 * 60 * 24   # for test
  @invite_key_expire_seconds 60 * 60 * 24 * 7

  def signin_key(token), do: "signin:" <> token

  def generate_signin_token(email, expire_seconds \\ @signin_key_expire_seconds) do
    token = put_signin_token(email)
    Cotoami.Redix.command!(["EXPIRE", signin_key(token), expire_seconds])
    token
  end

  def generate_invite_token(email) do
    generate_signin_token(email, @invite_key_expire_seconds)
  end

  # Ensure the newly generated signin token is unique
  defp put_signin_token(email) do
    token = 30 |> :crypto.strong_rand_bytes() |> Base.hex_encode32(case: :lower)
    case Cotoami.Redix.command!(["SETNX", signin_key(token), email]) do
      1 -> token
      0 -> put_signin_token(email)
    end
  end

  def get_signin_email(token) do
    email = Cotoami.Redix.command!(["GET", signin_key(token)])
    Cotoami.Redix.command!(["DEL", signin_key(token)])
    email
  end

  #
  # Gravatar profile cache
  #

  @gravatar_key_expire_seconds 60 * 10

  def gravatar_key(email), do: "gravatar:" <> email

  def get_gravatar_profile(email) do
    Cotoami.Redix.command!(["GET", gravatar_key(email)])
  end

  def get_gravatar_profiles([]), do: %{}
  def get_gravatar_profiles(emails) when is_list(emails) do
    gravatar_keys = Enum.map(emails, &gravatar_key(&1))
    profiles = Cotoami.Redix.command!(["MGET" | gravatar_keys])
    emails
    |> Enum.zip(profiles)
    |> Enum.into(%{})
  end

  def put_gravatar_profile(email, profile_json) do
    Cotoami.Redix.command!([
      "SETEX",
      gravatar_key(email),
      @gravatar_key_expire_seconds,
      profile_json
    ])
  end
end
