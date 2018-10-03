defmodule Cotoami.RedisService do
  @moduledoc """
  Provides Redis related functions.
  """

  require Logger
  alias Cotoami.Amishi

  #
  # Sign-in keys
  #

  @signin_key_expire_seconds 60 * 60 * 24

  def signin_key(token), do: "signin:" <> token
  
  def generate_signin_token(email) do
    token = generate_token(email, &signin_key/1)
    Cotoami.Redix.command!(["EXPIRE", signin_key(token), @signin_key_expire_seconds])
    token
  end

  def get_signin_email(token) do
    email = Cotoami.Redix.command!(["GET", signin_key(token)])
    Cotoami.Redix.command!(["DEL", signin_key(token)])
    email
  end

  #
  # Invite
  #

  @invite_key_expire_seconds 60 * 60 * 24 * 7

  def invite_key(token), do: "invite:" <> token

  def generate_invite_token(invitee_email, %Amishi{id: inviter_id}) do
    # inviter_id is the first because it's guaranteed not to contain commas
    token = generate_token("#{inviter_id},#{invitee_email}", &invite_key/1)
    Cotoami.Redix.command!(["EXPIRE", invite_key(token), @invite_key_expire_seconds])
    token
  end

  def get_invite(token) do
    value = Cotoami.Redix.command!(["GET", invite_key(token)])
    Cotoami.Redix.command!(["DEL", invite_key(token)])
    Logger.info "get_invite: #{inspect value}"
    case value do
      nil ->
        nil
      value ->
        [inviter_id, invitee_email] = String.split(value, ",", parts: 2)
        {invitee_email, inviter_id}
    end
  end

  #
  # Internal
  #
  
  defp generate_token(value, key_prefixer) do
    token = 30 |> :crypto.strong_rand_bytes() |> Base.hex_encode32(case: :lower)
    # Ensure the newly generated signin token is unique
    case Cotoami.Redix.command!(["SETNX", key_prefixer.(token), value]) do
      1 -> token
      0 -> generate_token(value, key_prefixer)
    end
  end
end
