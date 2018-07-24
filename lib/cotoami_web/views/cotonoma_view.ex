defmodule CotoamiWeb.CotonomaView do
  use CotoamiWeb, :view
  alias CotoamiWeb.{CotoView, AmishiView}

  def render("cotonomas.json", %{cotonomas: cotonomas}) do
    render_many(cotonomas, __MODULE__, "cotonoma.json")
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
end
