defmodule Cotoami.Email do
  use Bamboo.Phoenix, view: Cotoami.EmailView
  
  def signin_link(email_address) do
    new_email()
    |> to(email_address)
    |> from("no-reply@cotoa.me")
    |> subject("Sign in to Cotoami")
    |> text_body("Here’s the link you requested to get into Cotoami.")
  end
end
