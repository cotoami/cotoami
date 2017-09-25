defmodule Cotoami.Email do
  @moduledoc """
  Emails sent by Cotoami app
  """

  use Bamboo.Phoenix, view: Cotoami.EmailView

  def signin_link(email_address, token, host_url) do
    new_email()
    |> to(email_address)
    |> from({"Cotoami", from()})
    |> subject("Sign in to Cotoami")
    |> put_text_layout({Cotoami.LayoutView, "email.text"})
    |> render("signin_link.text",
      token: token,
      host_url: host_url)
  end

  defp from do
    :cotoami
    |> Application.get_env(__MODULE__, [])
    |> Keyword.get(:from)
  end
end
