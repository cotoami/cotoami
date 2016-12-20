defmodule Cotoami.Email do
  use Bamboo.Phoenix, view: Cotoami.EmailView
  
  @default_url_prefix "http://localhost:4000"
  
  def signin_link(email_address, token, anonymous_id) do
    new_email
    |> to(email_address)
    |> from({"Cotoami", from})
    |> subject("Sign in to Cotoami")
    |> put_text_layout({Cotoami.LayoutView, "email.text"})
    |> render("signin_link.text",
      url_prefix: url_prefix,
      token: token,
      anonymous_id: anonymous_id)
  end
  
  defp from do
    Application.get_env(:cotoami, __MODULE__, []) |> Keyword.get(:from)
  end
  
  defp url_prefix do
    Application.get_env(:cotoami, __MODULE__, []) |> Keyword.get(:url_prefix)
    || @default_url_prefix
  end
end
