defmodule CotoamiWeb.OAuth2Controller do
  use CotoamiWeb, :controller
  require Logger
  alias Cotoami.AmishiService
  alias CotoamiWeb.AuthPlug
  alias CotoamiWeb.OAuth2.Google
  alias CotoamiWeb.OAuth2.GitHub

  def providers do
    :cotoami
    |> Application.get_env(__MODULE__, [])
    |> Keyword.get(:providers)
  end

  def index(conn, %{"provider" => provider}) do
    if provider in providers() do
      redirect conn, external: authorize_url!(provider)
    else
      send_resp(conn, :unauthorized, "")
    end
  end

  def callback(conn, %{"provider" => provider, "code" => code}) do
    client = get_token!(provider, code)
    user = get_user!(provider, client)
    amishi = AmishiService.insert_or_update!(user)
    conn
    |> AuthPlug.start_session(amishi)
    |> put_session(:access_token, client.token.access_token)
    |> redirect(to: "/")
    |> halt()
  end

  defp authorize_url!("google"), do: Google.authorize_url!(scope: "https://www.googleapis.com/auth/userinfo.profile")
  defp authorize_url!("github"), do: GitHub.authorize_url!
  defp authorize_url!(_), do: raise "No matching provider available"

  defp get_token!("google", code), do: Google.get_token!(code: code)
  defp get_token!("github", code), do: GitHub.get_token!(code: code)
  defp get_token!(_, _), do: raise "No matching provider available"

  defp get_user!("google", client), do: Google.get_user!(client)
  defp get_user!("github", client), do: GitHub.get_user!(client)
end
