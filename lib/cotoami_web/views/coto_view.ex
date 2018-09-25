defmodule CotoamiWeb.CotoView do
  use CotoamiWeb, :view
  alias Cotoami.{Coto}
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
    render_one(coto, __MODULE__, "coto.json")
  end

  def render("coto.json", %{coto: coto}) do
    %{
      id: coto.id,
      content: Coto.get_content(coto),
      summary: coto.summary,
      amishi: render_relation(coto.amishi, AmishiView, "amishi.json"),
      posted_in: render_relation(coto.posted_in, CotonomaView, "cotonoma.json"),
      as_cotonoma: coto.as_cotonoma,
      cotonoma: render_relation(coto.cotonoma, CotonomaView, "cotonoma.json"),
      inserted_at: coto.inserted_at |> to_unixtime(),
      updated_at: coto.updated_at |> to_unixtime(),
    }
  end

  def render("export.json", %{coto: coto}) do
    %{
      id: coto.id,
      content: Coto.get_content(coto),
      summary: coto.summary,
      posted_in_id: coto.posted_in_id,
      as_cotonoma: coto.as_cotonoma,
      cotonoma: render_relation(coto.cotonoma, CotonomaView, "export.json"),
      inserted_at: coto.inserted_at |> to_unixtime(),
      updated_at: coto.updated_at |> to_unixtime(),
    }
  end

  defp to_unixtime(datetime) do
    if datetime, do: DateTime.to_unix(datetime, :millisecond), else: nil
  end
end
