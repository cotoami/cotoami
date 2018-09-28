defmodule Cotoami.GravatarService do
  @moduledoc """
  Provides Gravatar related functions.
  """

  require Logger
  alias Cotoami.EmailUser

  @gravatar_url_prefix "https://secure.gravatar.com/"
  @gravatar_user_agent "Cotoami"

  def get_user(email) do
    gravatar_profile = get_gravatar_profile(email) || %{}
    %EmailUser{
      email: email,
      name:
        Map.get(
          gravatar_profile,
          "displayName",
          get_default_name(email)
        ),
      avatar_url: get_gravatar_url(email)
    }
  end

  defp get_default_name(email) do
    email |> String.split("@") |> List.first()
  end

  def get_gravatar_url(email) do
    @gravatar_url_prefix <> "avatar/" <> email_hash(email)
  end

  def get_gravatar_profile(email) do
    case get_gravatar_profile_as_json(email) do
      nil -> nil
      json -> decode_gravatar_profile_json(json)
    end
  end

  defp decode_gravatar_profile_json(json) do
    case Poison.decode!(json) do
      %{"entry" => value} when is_list(value) -> List.first(value) || %{}
      _ -> %{}
    end
  end

  defp get_gravatar_profile_as_json(email) do
    url = @gravatar_url_prefix <> email_hash(email) <> ".json"
    Logger.info "Gravatar request <#{email}> - #{url}"
    response = HTTPotion.get url, [headers: ["User-Agent": @gravatar_user_agent]]
    Logger.info "Gravatar response <#{email}> - #{inspect response}"
    case response do
      %{status_code: 200, body: body} -> body
      %{status_code: 404} -> "{}"   # empty json object for caching
      _ -> nil
    end
  end

  defp email_hash(email) do
    :md5 |> :crypto.hash(email) |> Base.encode16(case: :lower)
  end
end
