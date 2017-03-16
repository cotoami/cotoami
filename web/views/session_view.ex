defmodule Cotoami.SessionView do
  use Cotoami.Web, :view
  alias Cotoami.AmishiView
  
  def render("session.json", %{amishi: amishi, token: token}) do
    render_one(amishi, AmishiView, "amishi.json")
    |> Map.put(:token, token)
  end
end
