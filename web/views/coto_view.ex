defmodule Cotoami.CotoView do
  use Cotoami.Web, :view
  alias Cotoami.Cotonoma
  
  def render("index.json", %{rows: rows}) do
    render_many(rows, __MODULE__, "coto.json")
  end
  
  def render("created.json", %{coto: coto, postId: postId}) do
    render_one(coto, __MODULE__, "coto.json")
    |> Map.put("postId", postId)
  end
  
  def render("coto.json", %{coto: coto}) do
    cotonoma_key = 
      case coto.cotonoma do
        %Cotonoma{key: key} -> key
        _ -> ""
      end
    %{
      id: coto.id,
      content: coto.content,
      as_cotonoma: coto.as_cotonoma,
      cotonoma_key: cotonoma_key,
      inserted_at: coto.inserted_at |> Ecto.DateTime.to_string(),
      updated_at: coto.updated_at |> Ecto.DateTime.to_string()
    }
  end
end
