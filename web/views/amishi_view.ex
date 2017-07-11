defmodule Cotoami.AmishiView do
  use Cotoami.Web, :view

  def render("amishi.json", %{amishi: amishi}) do
    %{
      id: amishi.id,
      email: amishi.email,
      avatar_url: Map.get(amishi, :avatar_url, ""),
      display_name: Map.get(amishi, :display_name, ""),
      inserted_at: amishi.inserted_at |> DateTime.to_unix(:microsecond),
      updated_at: amishi.updated_at |> DateTime.to_unix(:microsecond)
    }
  end
end
