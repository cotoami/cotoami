defmodule CotoamiWeb.OAuth2.Google do
  use OAuth2.Strategy
  alias Cotoami.ExternalUser

  defp common_config do
    [
      strategy: __MODULE__,
      site: "https://accounts.google.com",
      authorize_url: "/o/oauth2/auth",
      token_url: "/o/oauth2/token"
    ]
  end

  # Public API

  def client do
    Application.get_env(:cotoami, __MODULE__)
    |> Keyword.merge(common_config())
    |> OAuth2.Client.new()
  end

  def authorize_url!(params \\ []) do
    OAuth2.Client.authorize_url!(client(), params)
  end

  def get_token!(params \\ [], _headers \\ []) do
    OAuth2.Client.get_token!(
      client(), Keyword.merge(params, client_secret: client().client_secret))
  end

  def get_user!(client_with_token) do
    %{body: user} = 
      client_with_token
      |> OAuth2.Client.get!("https://www.googleapis.com/plus/v1/people/me/openIdConnect")
    %ExternalUser{
      auth_provider: "google",
      auth_id: user["sub"],
      name: user["name"], 
      avatar_url: user["picture"]
    }
  end

  # Strategy Callbacks

  def authorize_url(client, params) do
    OAuth2.Strategy.AuthCode.authorize_url(client, params)
  end

  def get_token(client, params, headers) do
    client
    |> put_param(:client_secret, client.client_secret)
    |> put_header("Accept", "application/json")
    |> OAuth2.Strategy.AuthCode.get_token(params, headers)
  end
end