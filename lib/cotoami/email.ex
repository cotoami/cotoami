defmodule Cotoami.Email do
  use Bamboo.Phoenix, view: Cotoami.EmailView
  
  def signin_link(email_address) do
    new_email
    |> to(email_address)
    |> from({"Cotoami", "no-reply@cotoa.me"})
    |> subject("Sign in to Cotoami")
    |> put_text_layout({Cotoami.LayoutView, "email.text"})
    |> render("signin_link.text")
  end
end
