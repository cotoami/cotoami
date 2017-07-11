defmodule Cotoami.Email do
  use Bamboo.Phoenix, view: Cotoami.EmailView

  def signin_link(email_address, token, anonymous_id, host_url) do
    new_email()
    |> to(email_address)
    |> from({"Cotoami", from()})
    |> subject("Sign in to Cotoami")
    |> put_text_layout({Cotoami.LayoutView, "email.text"})
    |> render("signin_link.text",
      token: token,
      anonymous_id: anonymous_id,
      host_url: host_url)
  end

  defp from do
    Application.get_env(:cotoami, __MODULE__, []) |> Keyword.get(:from)
  end
end
