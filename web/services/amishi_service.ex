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
  
  def create(email) do
    changeset = Amishi.changeset(%Amishi{}, %{email: email})
    Repo.insert!(changeset)
  end
  
  def get_gravatar_profile(email) do
    response = HTTPotion.get get_gravatar_url(email) <> ".json", 
      [headers: ["User-Agent": @gravatar_user_agent]]
    case response do
      %{status_code: 200, body: body} -> 
        Poison.decode!(body)
        |> Map.get("entry")
        |> List.first
      _ -> 
        nil
    end
  end
  
  def get_gravatar_url(email) do
    hash = :crypto.hash(:md5, email) |> Base.encode16(case: :lower)
    @gravatar_url_prefix <> hash
  end
end
