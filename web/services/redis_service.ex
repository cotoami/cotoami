defmodule Cotoami.RedisService do
  require Logger
  
  #
  # Anonymous posts
  #
  
  @anonymous_key_expire_seconds 60 * 60 * 24 * 30
  
  def anonymous_key(anonymous_id), do: "anonymous:" <> anonymous_id
  
  def get_cotos(anonymous_id) do
    cotos =
      case Cotoami.Redix.command(["LRANGE", anonymous_key(anonymous_id), "0", "1000"]) do
        {:ok, cotos} ->
          if cotos do
            Enum.map(cotos, fn coto ->
              Map.merge(Poison.decode!(coto), %{
                as_cotonoma: false, 
                cotonoma_key: ""
              })
            end)
          else
            []
          end
        {:error, reason} ->
          Logger.error "Redis error #{reason}"
          []
      end
    cotos
  end
  
  def add_coto(anonymous_id, coto) do
    coto_as_json = Poison.encode!(coto)
    count = Cotoami.Redix.command!(["LPUSH", anonymous_key(anonymous_id), coto_as_json])
    if count == 1 do
      Cotoami.Redix.command!(["EXPIRE", anonymous_key(anonymous_id), @anonymous_key_expire_seconds]) 
    end
  end
  
  def clear_cotos(anonymous_id) do
    Cotoami.Redix.command!(["DEL", anonymous_key(anonymous_id)])
  end
  
  
  #
  # Sign-in keys
  #
  
  # @signin_key_expire_seconds 60 * 10
  @signin_key_expire_seconds 60 * 60 * 24   # for test
  
  def signin_key(token), do: "signin:" <> token
  
  def generate_signin_token(email) do
    token = put_signin_token(email)
    Cotoami.Redix.command!(["EXPIRE", signin_key(token), @signin_key_expire_seconds]) 
    token
  end
  
  # Ensure the newly generated signin token is unique
  defp put_signin_token(email) do
    token = :crypto.strong_rand_bytes(30) |> Base.hex_encode32(case: :lower)
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
  
  def put_gravatar_profile(email, profile_json) do
    Cotoami.Redix.command!([
      "SETEX", 
      gravatar_key(email), 
      @gravatar_key_expire_seconds, 
      profile_json
    ])
  end  
end
