defmodule Cotoami.Email do
  @moduledoc """
  Emails sent by Cotoami app
  """

  use Bamboo.Phoenix, view: Cotoami.EmailView
  alias Cotoami.Amishi

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

  def invitation(email_address, token, host_url,
      %Amishi{email: inviter_email, display_name: inviter_name}) do
    new_email()
    |> to(email_address)
    |> from({"Cotoami", from()})
    |> subject("#{inviter_name} has invited you to join a Cotoami workspace")
    |> put_text_layout({Cotoami.LayoutView, "email.text"})
    |> render("invitation.text",
      token: token,
      host_url: host_url,
      inviter_email: inviter_email,
      inviter_name: inviter_name)
  end

  defp from do
    :cotoami
    |> Application.get_env(__MODULE__, [])
    |> Keyword.get(:from)
  end
end
