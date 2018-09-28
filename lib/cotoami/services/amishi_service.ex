defmodule Cotoami.AmishiService do
  @moduledoc """
  Provides Amishi related functions.
  """

  require Logger
  alias Cotoami.{Repo, Amishi, ExternalUser, RedisService}

  @gravatar_url_prefix "https://secure.gravatar.com/"
  @gravatar_user_agent "Cotoami"

  def owner_emails do
    :cotoami
    |> Application.get_env(__MODULE__, [])
    |> Keyword.get(:owner_emails)
  end

  def signup_enabled do
    :cotoami
    |> Application.get_env(__MODULE__, [])
    |> Keyword.get(:signup_enabled)
  end

  def is_allowed_to_signin?(email) do
    signup_enabled() || email in owner_emails() || get_by_email(email)
  end

  def get(id) do
    Amishi
    |> Repo.get(id)
    |> append_owner_flag()
    |> append_gravatar_profile()
  end

  def get_by_external_user(%ExternalUser{auth_provider: provider, auth_id: id}) do
    Repo.get_by(Amishi, auth_provider: provider, auth_id: id)
  end

  def insert_or_update_by_external_user!(%ExternalUser{} = user) do
    case get_by_external_user(user) do
      nil ->
        Amishi.changeset_to_insert(user)
        |> Repo.insert!()
      amishi ->
        Amishi.changeset_to_update(amishi, user)
        |> Repo.update!()
    end
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
    gravatar_profile = get_gravatar_profile(amishi.email)
    append_gravatar_profile(%Amishi{} = amishi, gravatar_profile)
  end
  def append_gravatar_profile(%Amishi{} = amishi, gravatar_profile) do
    gravatar_profile = gravatar_profile || %{}
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

  def append_gravatar_profiles(amishis) when is_list(amishis) do
    profiles =
      amishis
      |> Enum.map(&(&1.email))
      |> Enum.uniq()
      |> RedisService.get_gravatar_profiles()
      |> Map.to_list()
      |> Enum.map(fn({email, json}) ->
           case json do
             nil -> {email, do_get_and_cache_gravatar_profile(email)}
             json -> {email, decode_gravatar_profile_json(json)}
           end
         end)
      |> Enum.into(%{})
    Enum.map(amishis, &(append_gravatar_profile(&1, profiles[&1.email])))
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
      nil -> do_get_and_cache_gravatar_profile(email)
      json -> decode_gravatar_profile_json(json)
    end
  end

  defp decode_gravatar_profile_json(json) do
    case Poison.decode!(json) do
      %{"entry" => value} when is_list(value) -> List.first(value) || %{}
      _ -> %{}
    end
  end

  defp do_get_and_cache_gravatar_profile(email) do
    case do_get_gravatar_profile(email) do
      nil -> nil
      json ->
        RedisService.put_gravatar_profile(email, json)
        decode_gravatar_profile_json(json)
    end
  end

  defp do_get_gravatar_profile(email) do
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

  def get_gravatar_url(email) do
    @gravatar_url_prefix <> "avatar/" <> email_hash(email)
  end

  defp email_hash(email) do
    :md5 |> :crypto.hash(email) |> Base.encode16(case: :lower)
  end
end
