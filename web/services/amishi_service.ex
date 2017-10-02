defmodule Cotoami.AmishiService do
  @moduledoc """
  Provides Amishi related functions.
  """

  require Logger
  alias Cotoami.{Repo, Amishi, RedisService}

  @gravatar_url_prefix "https://secure.gravatar.com/"
  @gravatar_user_agent "Cotoami"

  def owner_emails do
    :cotoami
    |> Application.get_env(__MODULE__, [])
    |> Keyword.get(:owner_emails)
  end

  def get(id) do
    Amishi
    |> Repo.get(id)
    |> append_owner_flag()
    |> append_gravatar_profile()
  end

  def get_by_email(email) do
    Amishi
    |> Repo.get_by(email: email)
    |> append_owner_flag()
    |> append_gravatar_profile()
  end

  def append_owner_flag(nil), do: nil
  def append_owner_flag(%Amishi{} = amishi) do
    Map.put(amishi, :owner, amishi.email in owner_emails())
  end

  def append_gravatar_profile(nil), do: nil
  def append_gravatar_profile(%Amishi{} = amishi) do
    gravatar_profile = get_gravatar_profile(amishi.email) || %{}
    Map.merge(amishi, %{
      avatar_url: get_gravatar_url(amishi.email),
      display_name:
        Map.get(
          gravatar_profile,
          "displayName",
          get_default_display_name(amishi)
        )
    })
  end

  def get_default_display_name(%Amishi{email: email}) do
    email |> String.split("@") |> List.first()
  end

  def create!(email) do
    %Amishi{}
    |> Amishi.changeset(%{email: email})
    |> Repo.insert!
  end

  def get_gravatar_profile(email) do
    case RedisService.get_gravatar_profile(email) do
      nil ->
        case do_get_gravatar_profile(email) do
          nil -> nil
          json ->
            RedisService.put_gravatar_profile(email, json)
            decode_gravatar_profile_json(json)
        end
      json ->
        decode_gravatar_profile_json(json)
    end
  end

  defp decode_gravatar_profile_json(json) do
    json
    |> Poison.decode!()
    |> Map.get("entry")
    |> List.first
  end

  defp do_get_gravatar_profile(email) do
    url = @gravatar_url_prefix <> email_hash(email) <> ".json"
    Logger.info "Gravatar request <#{email}> - #{url}"
    response = HTTPotion.get url, [headers: ["User-Agent": @gravatar_user_agent]]
    Logger.info "Gravatar response <#{email}> - #{inspect response}"
    case response do
      %{status_code: 200, body: body} -> body
      _ -> nil
    end
  end

  def get_gravatar_url(email) do
    @gravatar_url_prefix <> "avatar/" <> email_hash(email)
  end

  defp email_hash(email) do
    :md5 |> :crypto.hash(email) |> Base.encode16(case: :lower)
  end
end
