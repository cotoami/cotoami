defmodule Cotoami.CotoView do
  use Cotoami.Web, :view
  alias Cotoami.Cotonoma
  alias Cotoami.CotonomaView
  alias Cotoami.AmishiView
  
  def render("index.json", %{rows: rows}) do
    render_many(rows, __MODULE__, "coto.json")
  end
  
  def render("created.json", %{coto: coto, postId: postId}) do
    render_one(coto, __MODULE__, "coto.json")
    |> Map.put("postId", postId)
  end
  
  def render("coto.json", %{coto: coto}) do
    posted_in_as_json =
      case coto.posted_in do
        %Ecto.Association.NotLoaded{} -> nil
        posted_in -> 
          render_one(posted_in, CotonomaView, "cotonoma.json")
      end
    cotonoma_key = 
      case coto.cotonoma do
        %Cotonoma{key: key} -> key
        _ -> ""
      end
    %{
      id: coto.id,
      content: coto.content,
      amishi: render_one(coto.amishi, AmishiView, "amishi.json"),
      posted_in: posted_in_as_json,
      as_cotonoma: coto.as_cotonoma,
      cotonoma_key: cotonoma_key,
      inserted_at: coto.inserted_at |> Ecto.DateTime.to_string(),
      updated_at: coto.updated_at |> Ecto.DateTime.to_string()
    }
  end
end
