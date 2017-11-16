defmodule Cotoami.CotoView do
  use Cotoami.Web, :view
  alias Cotoami.{Cotonoma, CotonomaView, AmishiView}

  def render("index.json", %{rows: rows}) do
    render_many(rows, __MODULE__, "coto.json")
  end

  def render("created.json", %{coto: coto}) do
    coto
    |> render_one(__MODULE__, "coto.json")
  end

  def render("coto.json", %{coto: coto}) do
    amishi_as_json =
      case coto.amishi do
        %Ecto.Association.NotLoaded{} -> nil
        amishi -> render_one(amishi, AmishiView, "amishi.json")
      end
    posted_in_as_json =
      case coto.posted_in do
        %Ecto.Association.NotLoaded{} -> nil
        posted_in -> render_one(posted_in, CotonomaView, "cotonoma.json")
      end
    cotonoma =
      case coto.cotonoma do
        %Cotonoma{} = cotonoma -> cotonoma
        _ -> %{}
      end
    %{
      id: coto.id,
      content: coto.content,
      summary: coto.summary,
      amishi: amishi_as_json,
      posted_in: posted_in_as_json,
      as_cotonoma: coto.as_cotonoma,
      cotonoma_id: Map.get(cotonoma, :id),
      cotonoma_key: Map.get(cotonoma, :key),
      cotonoma_pinned: Map.get(cotonoma, :pinned),
      cotonoma_timeline_rev: Map.get(cotonoma, :timeline_revision),
      cotonoma_graph_rev: Map.get(cotonoma, :graph_revision),
      inserted_at: coto.inserted_at |> DateTime.to_unix(:millisecond),
      updated_at: coto.updated_at |> DateTime.to_unix(:millisecond)
    }
  end
end
