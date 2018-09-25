defmodule Cotoami.CotoService do
  @moduledoc """
  Provides Coto related functions.
  """

  require Logger
  import Ecto.Query
  import Cotoami.ServiceHelpers
  alias Cotoami.{
    Repo, Coto, Cotonoma, Amishi,
    AmishiService, CotonomaService, CotoGraphService, CotoSearchService
  }
  alias Cotoami.Exceptions.InvalidOperation

  def get(id) do
    Coto
    |> preload([:amishi, :posted_in, :cotonoma])
    |> Repo.get(id)
  end

  def get_by_ids(coto_ids) do
    Coto
    |> where([c], c.id in ^coto_ids)
    |> preload([:amishi, :posted_in, :cotonoma])
    |> Repo.all()
  end

  def get_by_amishi(id, %Amishi{id: amishi_id} = amishi) do
    coto =
      Coto
      |> Coto.for_amishi(amishi_id)
      |> preload([:posted_in, :cotonoma])
      |> Repo.get(id)
    case coto do
      nil -> nil
      coto -> %{coto | amishi: amishi}
    end
  end

  @page_size 30

  def get_cotos_by_amishi(%Amishi{id: amishi_id} = amishi, page_index, options \\ []) do
    Coto
    |> Coto.for_amishi(amishi_id)
    |> order_by(desc: :inserted_at)
    |> query_to_exclude_pinned_graph(amishi_id, options)
    |> query_to_exclude_posts_in_cotonoma(amishi, options)
    |> preload([:posted_in, :cotonoma])
    |> query_with_pagination(@page_size, page_index, &(complement_amishi(&1, amishi)))
  end

  def get_cotos_by_cotonoma(key, %Amishi{} = amishi, page_index, options \\ []) do
    case CotonomaService.get_by_key(key) do
      nil -> nil
      cotonoma ->
        Cotonoma.ensure_accessible_by(cotonoma, amishi)
        Coto
        |> Coto.in_cotonoma(cotonoma.id)
        |> order_by(desc: :inserted_at)
        |> query_to_exclude_pinned_graph(cotonoma.coto.id, options)
        |> preload([:amishi, :posted_in, :cotonoma])
        |> query_with_pagination(@page_size, page_index, &(complement_amishi(&1, amishi)))
        |> Map.put(:cotonoma, cotonoma)
    end
  end

  defp query_to_exclude_pinned_graph(query, uuid, options) do
    if Keyword.get(options, :exclude_pinned_graph, false) do
      coto_ids = 
        CotoGraphService.get_graph_from_uuid(Bolt.Sips.conn, uuid)
        |> Map.get(:cotos)
        |> Map.keys()
      from coto in query, where: not(coto.id in ^coto_ids)
    else
      query
    end
  end

  defp query_to_exclude_posts_in_cotonoma(query, %Amishi{}, options) do
    if Keyword.get(options, :exclude_posts_in_cotonoma, false) do
      from coto in query, where: is_nil(coto.posted_in_id)
    else
      query
    end
  end

  def search(query, %Amishi{} = amishi) do
    Coto
    |> CotoSearchService.search(amishi, query)
    |> preload([:amishi, :posted_in, :cotonoma])
    |> limit(@page_size)
    |> Repo.all()
    |> Enum.map(&(complement_amishi(&1, amishi)))
  end

  def complement(%Coto{} = coto, %Amishi{} = amishi) do
    coto
    |> complement_cotonoma()
    |> complement_amishi(amishi)
  end

  def complement_cotonoma(%Coto{} = coto) do
    if coto.cotonoma do
      %{coto | cotonoma: CotonomaService.complement_owner(coto.cotonoma)}
    else
      coto
    end
  end

  def complement_amishi(%Coto{} = coto, %Amishi{id: amishi_id} = amishi) do
    if coto.amishi_id == amishi_id do
      %{coto | amishi: amishi}
    else
      case coto.amishi do
        %Ecto.Association.NotLoaded{} ->
          %{coto | amishi: AmishiService.get(coto.amishi_id)}
        amishi ->
          %{coto | amishi: AmishiService.append_gravatar_profile(amishi)}
      end
    end
  end

  def export_by_amishi(%Amishi{id: amishi_id}) do
    Coto
    |> Coto.for_amishi(amishi_id)
    |> order_by(asc: :inserted_at)
    |> preload([:cotonoma])
    |> Repo.all()
  end

  def create!(%Amishi{id: amishi_id}, content, summary \\ nil, cotonoma_id \\ nil) do
    posted_in = CotonomaService.get!(cotonoma_id)
    coto =
      %Coto{}
      |> Coto.changeset_to_insert(%{
          content: content,
          summary: summary,
          as_cotonoma: false,
          posted_in_id: cotonoma_id,
          amishi_id: amishi_id
        })
      |> Repo.insert!
    {coto, posted_in}
  end

  def update!(id, %{"content" => _, "shared" => shared} = params, %Amishi{id: amishi_id} = amishi) do
    Coto
    |> Coto.for_amishi(amishi_id)
    |> Repo.get!(id)
    |> Coto.changeset_to_update(params)
    |> Repo.update!()

    coto = get(id)  # updated struct with the relations
    cotonoma = 
      if coto.as_cotonoma do
        coto.cotonoma
        |> Cotonoma.changeset_to_update(%{name: coto.content, shared: shared})
        |> Repo.update!()
      else
        nil
      end

    CotoGraphService.sync_coto_props(Bolt.Sips.conn, coto)

    %{coto | 
      posted_in: CotonomaService.complement_owner(coto.posted_in),
      cotonoma: cotonoma
    }
    |> complement_amishi(amishi)
  end

  def delete!(id, %Amishi{id: amishi_id}) do
    coto =
      Coto
      |> Coto.for_amishi(amishi_id)
      |> preload([:posted_in, :cotonoma])
      |> Repo.get!(id)

    if coto.cotonoma do
      case CotonomaService.stats(coto.cotonoma) do
        %{cotos: 0, connections: 0} -> Repo.delete!(coto.cotonoma)
        _ -> raise InvalidOperation
      end
    end
    Repo.delete!(coto)
    CotoGraphService.delete_coto(Bolt.Sips.conn, id)

    CotonomaService.complement_owner(coto.posted_in)
  end
end
