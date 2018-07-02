defmodule CotoamiWeb.CotoView do
  use CotoamiWeb, :view
  alias Cotoami.{Coto, Cotonoma}
  alias CotoamiWeb.{CotonomaView, AmishiView}

  def render("cotos.json", %{
    rows: rows, 
    page_index: page_index, 
    total_pages: total_pages
  }) do
    %{
      cotos: render_many(rows, __MODULE__, "coto.json"),
      page_index: page_index,
      total_pages: total_pages
    }
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
      content: Coto.get_content(coto),
      summary: coto.summary,
      amishi: amishi_as_json,
      posted_in: posted_in_as_json,
      as_cotonoma: coto.as_cotonoma,
      inserted_at: coto.inserted_at |> to_unixtime(),
      updated_at: coto.updated_at |> to_unixtime(),

      # as_cotonoma
      cotonoma_id: Map.get(cotonoma, :id),
      cotonoma_key: Map.get(cotonoma, :key),
      cotonoma_pinned: Map.get(cotonoma, :pinned),
      cotonoma_timeline_rev: Map.get(cotonoma, :timeline_revision),
      cotonoma_graph_rev: Map.get(cotonoma, :graph_revision),
      cotonoma_inserted_at: Map.get(cotonoma, :inserted_at) |> to_unixtime(),
      cotonoma_updated_at: Map.get(cotonoma, :updated_at) |> to_unixtime()
    }
  end

  defp to_unixtime(datetime) do
    if datetime, do: DateTime.to_unix(datetime, :millisecond), else: nil
  end
end
