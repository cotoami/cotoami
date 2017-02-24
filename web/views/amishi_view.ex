defmodule Cotoami.AmishiView do
  use Cotoami.Web, :view
  
  def render("amishi.json", %{amishi: amishi}) do
    %{
      id: amishi.id,
      email: amishi.email,
      avatar_url: amishi.avatar_url,
      display_name: amishi.display_name,
      inserted_at: amishi.inserted_at |> Ecto.DateTime.to_string(),
      updated_at: amishi.updated_at |> Ecto.DateTime.to_string()
    }
  end
end
