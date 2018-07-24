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
    coto
    |> render_one(__MODULE__, "coto.json")
  end

  def render("coto.json", %{coto: coto}) do
    amishi =
      case coto.amishi do
        %Ecto.Association.NotLoaded{} -> nil
        amishi -> render_one(amishi, AmishiView, "amishi.json")
      end
    posted_in =
      case coto.posted_in do
        %Ecto.Association.NotLoaded{} -> nil
        posted_in -> render_one(posted_in, CotonomaView, "cotonoma.json")
      end
    cotonoma =
      case coto.cotonoma do
        %Ecto.Association.NotLoaded{} -> nil
        cotonoma -> render_one(cotonoma, CotonomaView, "cotonoma.json")
      end
    %{
      id: coto.id,
      content: Coto.get_content(coto),
      summary: coto.summary,
      amishi: amishi,
      posted_in: posted_in,
      as_cotonoma: coto.as_cotonoma,
      cotonoma: cotonoma,
      inserted_at: coto.inserted_at |> to_unixtime(),
      updated_at: coto.updated_at |> to_unixtime(),
    }
  end

  defp to_unixtime(datetime) do
    if datetime, do: DateTime.to_unix(datetime, :millisecond), else: nil
  end
end
