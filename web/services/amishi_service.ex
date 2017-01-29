defmodule Cotoami.AmishiService do
  require Logger
  alias Cotoami.Repo
  alias Cotoami.Amishi
  
  @gravatar_url_prefix "https://secure.gravatar.com/"
  @gravatar_user_agent "Cotoami"
  
  def get(id) do
    Amishi |> Repo.get(id)
  end
  
  def get_by_email(email) do
    Amishi |> Repo.get_by(email: email)
  end
  
  def create!(email) do
    Amishi.changeset(%Amishi{}, %{email: email})
    |> Repo.insert!
  end
  
  def get_gravatar_profile(email) do
    url = @gravatar_url_prefix <> email_hash(email) <> ".json"
    response = HTTPotion.get url, [headers: ["User-Agent": @gravatar_user_agent]]
    case response do
      %{status_code: 200, body: body} -> 
        Poison.decode!(body)
        |> Map.get("entry")
        |> List.first
      _ -> 
        %{}
    end
  end
  
  def get_gravatar_url(email) do
    @gravatar_url_prefix <> "avatar/" <> email_hash(email)
  end 
  
  defp email_hash(email) do
    :crypto.hash(:md5, email) |> Base.encode16(case: :lower)
  end
end
