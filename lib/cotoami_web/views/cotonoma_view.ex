defmodule CotoamiWeb.CotonomaView do
  use CotoamiWeb, :view
  alias CotoamiWeb.{CotoView, AmishiView}

  def render("index.json", %{pinned: pinned, recent: recent}) do
    %{
      pinned: render_many(pinned, __MODULE__, "cotonoma.json"),
      recent: render_many(recent, __MODULE__, "cotonoma.json")
    }
  end

  def render("sub.json", %{rows: rows}) do
    render_many(rows, __MODULE__, "cotonoma.json")
  end

  def render("cotos.json", %{
    cotonoma: cotonoma,
    rows: rows,
    page_index: page_index, 
    total_pages: total_pages
  }) do
    %{
      cotonoma: render_one(cotonoma, __MODULE__, "cotonoma.json"),
      paginated_cotos: render(CotoView, "cotos.json", 
        rows: rows,
        page_index: page_index, 
        total_pages: total_pages
      )
    }
  end

  def render("cotonoma.json", %{cotonoma: cotonoma}) do
    owner_as_json =
      case cotonoma.owner do
        %Ecto.Association.NotLoaded{} -> nil
        owner ->
          render_one(owner, AmishiView, "amishi.json")
      end
    %{
      id: cotonoma.id,
      key: cotonoma.key,
      name: cotonoma.name,
      shared: cotonoma.shared,
      pinned: cotonoma.pinned,
      timeline_revision: cotonoma.timeline_revision,
      graph_revision: cotonoma.graph_revision,
      coto_id:
        case cotonoma.coto do
          %Ecto.Association.NotLoaded{} -> ""
          coto -> coto.id
        end,
      owner: owner_as_json,
      inserted_at: cotonoma.inserted_at |> DateTime.to_unix(:millisecond),
      updated_at: cotonoma.updated_at |> DateTime.to_unix(:millisecond)
    }
  end
end
