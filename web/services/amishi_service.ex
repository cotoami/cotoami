defmodule Cotoami.AmishiService do
  require Logger
  alias Cotoami.Repo
  alias Cotoami.Amishi
  alias Cotoami.RedisService
  
  @gravatar_url_prefix "https://secure.gravatar.com/"
  @gravatar_user_agent "Cotoami"
  
  def get(id) do
    Amishi |> Repo.get(id)
  end
  
  def get_by_email(email) do
    Amishi |> Repo.get_by(email: email)
  end
  
  def append_gravatar_profile(amishi) do
    gravatar_profile = get_gravatar_profile(amishi.email)
    Logger.info "gravatar_profile: #{inspect gravatar_profile}"
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
  
  def get_default_display_name(amishi) do
    String.split(amishi.email, "@") |> List.first()
  end
  
  def create!(email) do
    Amishi.changeset(%Amishi{}, %{email: email})
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
    Poison.decode!(json)
    |> Map.get("entry")
    |> List.first
  end
  
  defp do_get_gravatar_profile(email) do
    url = @gravatar_url_prefix <> email_hash(email) <> ".json"
    response = HTTPotion.get url, [headers: ["User-Agent": @gravatar_user_agent]]
    case response do
      %{status_code: 200, body: body} -> body
      _ -> nil
    end
  end
  
  def get_gravatar_url(email) do
    @gravatar_url_prefix <> "avatar/" <> email_hash(email)
  end 
  
  defp email_hash(email) do
    :crypto.hash(:md5, email) |> Base.encode16(case: :lower)
  end
end
