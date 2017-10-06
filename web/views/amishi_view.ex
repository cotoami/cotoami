defmodule Cotoami.AmishiView do
  use Cotoami.Web, :view

  def render("amishi.json", %{amishi: amishi}) do
    %{
      id: amishi.id,
      email: amishi.email,
      owner: Map.get(amishi, :owner, false),
      avatar_url: Map.get(amishi, :avatar_url, ""),
      display_name: Map.get(amishi, :display_name, ""),
      inserted_at: amishi.inserted_at |> DateTime.to_unix(:millisecond),
      updated_at: amishi.updated_at |> DateTime.to_unix(:millisecond)
    }
  end
end
