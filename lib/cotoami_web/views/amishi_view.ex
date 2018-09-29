defmodule CotoamiWeb.AmishiView do
  use CotoamiWeb, :view

  def render("amishi.json", %{amishi: amishi}) do
    %{
      id: amishi.id,
      email: amishi.email,
      auth_provider: amishi.auth_provider,
      avatar_url: amishi.avatar_url || "",
      display_name: amishi.name || "",
      owner: Map.get(amishi, :owner, false),
      inserted_at: amishi.inserted_at |> DateTime.to_unix(:millisecond),
      updated_at: amishi.updated_at |> DateTime.to_unix(:millisecond)
    }
  end

  def render("export.json", %{amishi: amishi}) do
    %{
      id: amishi.id,
      email: amishi.email,
      avatar_url: amishi.avatar_url || "",
      display_name: amishi.name || "",
      owner: Map.get(amishi, :owner, false),
      inserted_at: amishi.inserted_at |> DateTime.to_unix(:millisecond),
      updated_at: amishi.updated_at |> DateTime.to_unix(:millisecond)
    }
  end
end
