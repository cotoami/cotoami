defmodule CotoamiWeb.CotonomaView do
  use CotoamiWeb, :view
  alias CotoamiWeb.{CotoView, AmishiView}

  def render("index.json", %{
        global: global_cotonomas,
        recent: recent_cotonomas
      }) do
    %{
      global: render_many(global_cotonomas, __MODULE__, "cotonoma.json"),
      recent: render_many(recent_cotonomas, __MODULE__, "cotonoma.json")
    }
  end

  def render("cotonomas.json", %{cotonomas: cotonomas}) do
    render_many(cotonomas, __MODULE__, "cotonoma.json")
  end

  def render("cotonoma.json", %{cotonoma: cotonoma}) do
    %{
      id: cotonoma.id,
      key: cotonoma.key,
      name: cotonoma.name,
      shared: cotonoma.shared,
      pinned: cotonoma.pinned,
      timeline_revision: cotonoma.timeline_revision,
      graph_revision: cotonoma.graph_revision,
      coto_id: cotonoma.coto_id,
      owner: render_relation(cotonoma.owner, AmishiView, "amishi.json"),
      inserted_at: cotonoma.inserted_at |> to_unixtime(),
      updated_at: cotonoma.updated_at |> to_unixtime(),
      last_post_timestamp: cotonoma.last_post_timestamp |> to_unixtime()
    }
  end

  def render("export.json", %{cotonoma: cotonoma}) do
    %{
      id: cotonoma.id,
      key: cotonoma.key,
      name: cotonoma.name,
      shared: cotonoma.shared,
      pinned: cotonoma.pinned,
      timeline_revision: cotonoma.timeline_revision,
      graph_revision: cotonoma.graph_revision,
      inserted_at: cotonoma.inserted_at |> to_unixtime(),
      updated_at: cotonoma.updated_at |> to_unixtime(),
      last_post_timestamp: cotonoma.last_post_timestamp |> to_unixtime()
    }
  end

  def render("paginated_cotos.json", %{
        cotonoma: cotonoma,
        rows: rows,
        page_index: page_index,
        total_pages: total_pages
      }) do
    %{
      cotonoma: render_one(cotonoma, __MODULE__, "cotonoma.json"),
      paginated_cotos:
        render(
          CotoView,
          "paginated_cotos.json",
          rows: rows,
          page_index: page_index,
          total_pages: total_pages
        )
    }
  end
end
