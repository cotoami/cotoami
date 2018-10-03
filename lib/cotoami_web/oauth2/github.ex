defmodule CotoamiWeb.OAuth2.GitHub do
  use OAuth2.Strategy
  require Logger
  alias Cotoami.ExternalUser

  defp common_config do
    [
      strategy: __MODULE__,
      site: "https://api.github.com",
      authorize_url: "https://github.com/login/oauth/authorize",
      token_url: "https://github.com/login/oauth/access_token"
    ]
  end

  # Public API

  def client do
    Application.get_env(:cotoami, __MODULE__)
    |> Keyword.merge(common_config())
    |> OAuth2.Client.new()
  end

  def authorize_url!() do
    OAuth2.Client.authorize_url!(client(), [])
  end

  def get_token!(params \\ [], _headers \\ []) do
    OAuth2.Client.get_token!(
      client(), Keyword.merge(params, client_secret: client().client_secret))
  end

  def get_user!(client_with_token) do
    %{body: user} = OAuth2.Client.get!(client_with_token, "/user")
    Logger.info "OAuth2 user: #{inspect user}"
    %ExternalUser{
      auth_provider: "github",
      auth_id: user["node_id"],
      name: user["name"], 
      avatar_url: user["avatar_url"]
    }
  end

  # Strategy Callbacks

  def authorize_url(client, params) do
    OAuth2.Strategy.AuthCode.authorize_url(client, params)
  end

  def get_token(client, params, headers) do
    client
    |> put_header("Accept", "application/json")
    |> OAuth2.Strategy.AuthCode.get_token(params, headers)
  end
end
