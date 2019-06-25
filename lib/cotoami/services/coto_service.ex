defmodule Cotoami.CotoService do
  @moduledoc """
  Provides Coto related functions.
  """

  require Logger
  import Ecto.Query
  import Ecto.Changeset
  import Cotoami.ServiceHelpers

  alias Cotoami.{
    Repo,
    Coto,
    Cotonoma,
    Amishi,
    CotonomaService,
    CotoGraphService,
    CotoSearchService
  }

  alias Cotoami.Exceptions.InvalidOperation

  def get(id) do
    Coto
    |> preload([:amishi, :posted_in, :cotonoma, :repost])
    |> Repo.get(id)
  end

  def get_by_amishi(id, %Amishi{id: amishi_id} = amishi) do
    coto =
      Coto
      |> Coto.for_amishi(amishi_id)
      |> preload([:posted_in, :cotonoma, :repost])
      |> Repo.get(id)

    case coto do
      nil -> nil
      coto -> %{coto | amishi: amishi}
    end
  end

  def all_by_ids(coto_ids) do
    Coto
    |> where([c], c.id in ^coto_ids)
    |> preload([:amishi, :posted_in, :cotonoma, :repost])
    |> Repo.all()
  end

  @page_size 30

  def all_by_amishi(%Amishi{} = amishi, page_index, options \\ []) do
    query_by_amishi(amishi, options)
    |> order_by(desc: :inserted_at)
    |> query_with_pagination(@page_size, page_index, &complement_amishi(&1, amishi))
  end

  def all_by_cotonoma(%Cotonoma{} = cotonoma, %Amishi{} = amishi, page_index, options \\ []) do
    query_by_cotonoma(cotonoma, amishi, options)
    |> order_by(desc: :inserted_at)
    |> query_with_pagination(@page_size, page_index)
  end

  @random_limit 100

  def random_by_amishi(%Amishi{} = amishi, options \\ []) do
    query_by_amishi(amishi, options)
    |> order_by(fragment("random()"))
    |> limit(@random_limit)
    |> Repo.all()
    |> Enum.map(&complement_amishi(&1, amishi))
  end

  def random_by_cotonoma(%Cotonoma{} = cotonoma, %Amishi{} = amishi, options \\ []) do
    query_by_cotonoma(cotonoma, amishi, options)
    |> order_by(fragment("random()"))
    |> limit(@random_limit)
    |> Repo.all()
  end

  defp query_by_amishi(%Amishi{id: amishi_id} = amishi, options) do
    Coto
    |> Coto.for_amishi(amishi_id)
    |> query_to_exclude_pinned_graph(amishi_id, options)
    |> query_to_exclude_posts_in_cotonoma(amishi, options)
    |> preload([:posted_in, :cotonoma, :repost])
  end

  defp query_by_cotonoma(%Cotonoma{} = cotonoma, %Amishi{} = amishi, options) do
    Cotonoma.ensure_accessible_by(cotonoma, amishi)

    Coto
    |> Coto.in_cotonoma(cotonoma.id)
    |> query_to_exclude_pinned_graph(cotonoma.coto.id, options)
    |> preload([:amishi, :posted_in, :cotonoma, :repost])
  end

  defp query_to_exclude_pinned_graph(query, uuid, options) do
    if Keyword.get(options, :exclude_pinned_graph, false) do
      coto_ids =
        CotoGraphService.get_graph_from_uuid(Bolt.Sips.conn(), uuid)
        |> Map.get(:cotos)
        |> Map.keys()

      from(coto in query, where: not (coto.id in ^coto_ids))
    else
      query
    end
  end

  defp query_to_exclude_posts_in_cotonoma(query, %Amishi{}, options) do
    if Keyword.get(options, :exclude_posts_in_cotonoma, false) do
      from(coto in query, where: is_nil(coto.posted_in_id))
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
    |> Enum.map(&complement_amishi(&1, amishi))
  end

  def complement(%Coto{} = coto, %Amishi{} = amishi) do
    coto
    |> complement_amishi(amishi)
    |> Repo.preload(cotonoma: :owner)
  end

  def complement_amishi(%Coto{} = coto, %Amishi{id: amishi_id} = amishi) do
    if coto.amishi_id == amishi_id do
      %{coto | amishi: amishi}
    else
      Repo.preload(coto, :amishi)
    end
  end

  def export_by_amishi(%Amishi{id: amishi_id}) do
    Coto
    |> Coto.for_amishi(amishi_id)
    |> order_by(asc: :inserted_at)
    |> preload([:cotonoma])
    |> Repo.all()
  end

  def create!(content, summary, %Amishi{} = amishi),
    do: do_create!(content, summary, amishi, nil)

  def create!(content, summary, %Amishi{} = amishi, %Cotonoma{id: cotonoma_id}),
    do: do_create!(content, summary, amishi, cotonoma_id)

  defp do_create!(content, summary, %Amishi{id: amishi_id} = amishi, cotonoma_id) do
    {:ok, coto} =
      Repo.transaction(fn ->
        Coto.changeset_to_insert(%{
          content: content,
          summary: summary,
          as_cotonoma: false,
          posted_in_id: cotonoma_id,
          amishi_id: amishi_id
        })
        |> Repo.insert!()
        |> on_created()
      end)

    %{coto | amishi: amishi}
  end

  def on_created(%Coto{} = coto) do
    coto = Repo.preload(coto, :posted_in)

    case coto.posted_in do
      nil -> %{coto | posted_in: nil}
      cotonoma -> %{coto | posted_in: CotonomaService.update_on_post(cotonoma, coto)}
    end
  end

  def repost!(%Coto{} = coto, %Amishi{} = amishi),
    do: do_repost!(coto, amishi, nil)

  def repost!(%Coto{} = coto, %Amishi{} = amishi, %Cotonoma{id: cotonoma_id}),
    do: do_repost!(coto, amishi, cotonoma_id)

  defp do_repost!(coto, amishi, cotonoma_id) do
    coto =
      coto
      |> Repo.preload(:repost)
      |> Coto.peel!()

    if Coto.posted_in(coto, cotonoma_id) do
      raise Cotoami.Exceptions.DuplicateRepost
    end

    {:ok, repost} =
      Repo.transaction(fn ->
        # update reposted_in_ids of the reposted coto
        coto =
          case cotonoma_id do
            nil ->
              coto

            cotonoma_id ->
              coto
              |> change(reposted_in_ids: [cotonoma_id | coto.reposted_in_ids])
              |> Repo.update!()
              |> complement(amishi)
          end

        repost =
          Coto.changeset_to_repost(coto, amishi, cotonoma_id)
          |> Repo.insert!()
          |> on_created()

        %{repost | repost: coto}
      end)

    %{repost | amishi: amishi}
  end

  def update!(id, %{"content" => _, "shared" => shared} = params, %Amishi{id: amishi_id} = amishi) do
    Coto
    |> Coto.for_amishi(amishi_id)
    |> Repo.get!(id)
    |> Coto.changeset_to_update(params)
    |> Repo.update!()

    # updated struct with the relations
    coto = get(id)

    cotonoma =
      if coto.as_cotonoma do
        coto.cotonoma
        |> Cotonoma.changeset_to_update(%{name: coto.content, shared: shared})
        |> Repo.update!()
        |> (&%{&1 | owner: amishi}).()
      else
        nil
      end

    CotoGraphService.sync(Bolt.Sips.conn(), coto)

    %{coto | posted_in: Repo.preload(coto.posted_in, :owner), cotonoma: cotonoma}
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
    CotoGraphService.delete_coto(Bolt.Sips.conn(), id)

    coto
  end
end
