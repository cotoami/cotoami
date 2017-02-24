defmodule Cotoami.CotonomaView do
  use Cotoami.Web, :view
  alias Cotoami.CotoView
  
  def render("index.json", %{rows: rows}) do
    render_many(rows, __MODULE__, "cotonoma.json")
  end
  
  def render("cotos.json", %{cotonoma: cotonoma, cotos: cotos}) do
    %{
      cotonoma: render_one(cotonoma, __MODULE__, "cotonoma.json"),
      cotos: render_many(cotos, CotoView, "coto.json")
    }
  end
  
  def render("cotonoma.json", %{cotonoma: cotonoma}) do
    %{
      id: cotonoma.id,
      key: cotonoma.key,
      name: cotonoma.name,
      coto_id: 
        case cotonoma.coto do
          %Ecto.Association.NotLoaded{} -> -1
          coto -> coto.id
        end,
      inserted_at: cotonoma.inserted_at |> Ecto.DateTime.to_string(),
      updated_at: cotonoma.updated_at |> Ecto.DateTime.to_string()
    }
  end
end
