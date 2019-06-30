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

  @preload_repost [repost: [:amishi, :posted_in, :cotonoma]]

  def get(id) do
    get!(id)
  rescue
    _ in Ecto.NoResultsError -> nil
  end

  def get!(id) do
    Coto
    |> preload([:amishi, :posted_in, :cotonoma])
    |> preload(^@preload_repost)
    |> Repo.get!(id)
  end

  def get_by_amishi(id, %Amishi{} = amishi) do
    get_by_amishi!(id, amishi)
  rescue
    _ in Ecto.NoResultsError -> nil
  end

  def get_by_amishi!(id, %Amishi{id: amishi_id} = amishi) do
    Coto
    |> Coto.for_amishi(amishi_id)
    |> preload([:posted_in, :cotonoma])
    |> preload(^@preload_repost)
    |> Repo.get!(id)
    |> (&%{&1 | amishi: amishi}).()
  end

  def repost_ids(id) do
    from(coto in Coto, where: coto.repost_id == ^id, select: coto.id) |> Repo.all()
  end

  def all_by_ids(coto_ids) do
    Coto
    |> where([c], c.id in ^coto_ids)
    |> preload([:amishi, :posted_in, :cotonoma])
    |> preload(^@preload_repost)
    |> Repo.all()
  end

  @page_size 30

  def all_by_amishi(%Amishi{} = amishi, page_index, options \\ []) do
    query_by_amishi(amishi, options)
    |> order_by(desc: :inserted_at)
    |> query_with_pagination(@page_size, page_index, &complement_amishi(&1, amishi))
    |> set_reposted_in(amishi)
  end

  def all_by_cotonoma(%Cotonoma{} = cotonoma, %Amishi{} = amishi, page_index, options \\ []) do
    query_by_cotonoma(cotonoma, amishi, options)
    |> order_by(desc: :inserted_at)
    |> query_with_pagination(@page_size, page_index)
    |> set_reposted_in(amishi)
  end

  @random_limit 100

  def random_by_amishi(%Amishi{} = amishi, options \\ []) do
    query_by_amishi(amishi, options)
    |> order_by(fragment("random()"))
    |> limit(@random_limit)
    |> Repo.all()
    |> Enum.map(&complement_amishi(&1, amishi))
    |> set_reposted_in(amishi)
  end

  def random_by_cotonoma(%Cotonoma{} = cotonoma, %Amishi{} = amishi, options \\ []) do
    query_by_cotonoma(cotonoma, amishi, options)
    |> order_by(fragment("random()"))
    |> limit(@random_limit)
    |> Repo.all()
    |> set_reposted_in(amishi)
  end

  defp query_by_amishi(%Amishi{id: amishi_id} = amishi, options) do
    Coto
    |> Coto.for_amishi(amishi_id)
    |> query_to_exclude_pinned_graph(amishi_id, options, amishi)
    |> query_to_exclude_posts_in_cotonoma(amishi, options)
    |> preload([:posted_in, :cotonoma])
    |> preload(^@preload_repost)
  end

  defp query_by_cotonoma(%Cotonoma{} = cotonoma, %Amishi{} = amishi, options) do
    Cotonoma.ensure_accessible_by(cotonoma, amishi)

    Coto
    |> Coto.in_cotonoma(cotonoma.id)
    |> query_to_exclude_pinned_graph(cotonoma.coto.id, options, amishi)
    |> preload([:amishi, :posted_in, :cotonoma])
    |> preload(^@preload_repost)
  end

  defp query_to_exclude_pinned_graph(query, uuid, options, amishi) do
    if Keyword.get(options, :exclude_pinned_graph, false) do
      coto_ids =
        CotoGraphService.get_graph_from_uuid(Bolt.Sips.conn(), uuid, amishi)
        |> Map.get(:cotos)
        |> Map.keys()

      from(coto in query, where: not (coto.id in ^coto_ids))
    else
      query
    end
  end

  defp query_to_exclude_posts_in_cotonoma(query, %Amishi{}, options) do
    if Keyword.get(options, :exclude_posts_in_cotonoma, false) do
      from(coto in query,
        where: is_nil(coto.posted_in_id) and fragment("? = '{}'", coto.reposted_in_ids)
      )
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
    |> set_reposted_in(amishi)
  end

  def complement(%Coto{} = coto, %Amishi{} = amishi) do
    coto
    |> complement_amishi(amishi)
    |> Repo.preload([posted_in: [:owner], cotonoma: [:owner]] ++ @preload_repost)
    |> set_reposted_in(amishi)
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

  defp set_reposted_in(%Coto{} = coto, %Amishi{} = amishi) do
    [updated_coto] = set_reposted_in([coto], amishi)
    updated_coto
  end

  defp set_reposted_in(cotos, %Amishi{} = amishi) when is_list(cotos) do
    all_reposted_cotonomas =
      cotos
      |> Enum.map(&Coto.peel!/1)
      |> Enum.map(& &1.reposted_in_ids)
      |> List.flatten()
      |> Enum.uniq()
      |> CotonomaService.accessible_map_by_ids(amishi)

    collect_reposted_in = fn coto, cotonomas ->
      coto.reposted_in_ids
      |> Enum.map(&cotonomas[&1])
      |> Enum.filter(& &1)
    end

    cotos
    |> Enum.map(fn coto ->
      case coto do
        %Coto{repost: nil} ->
          reposted_in = collect_reposted_in.(coto, all_reposted_cotonomas)
          Map.put(coto, :reposted_in, reposted_in)

        %Coto{repost: repost} ->
          reposted_in = collect_reposted_in.(repost, all_reposted_cotonomas)
          repost = Map.put(repost, :reposted_in, reposted_in)
          %{coto | repost: repost}
      end
    end)
  end

  defp set_reposted_in(%{rows: rows} = paginated_cotos, %Amishi{} = amishi) do
    %{paginated_cotos | rows: set_reposted_in(rows, amishi)}
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

    %{coto | amishi: amishi, repost: nil}
  end

  def on_created(%Coto{} = coto) do
    coto = Repo.preload(coto, posted_in: [:owner])

    case coto.posted_in do
      nil -> coto
      posted_in -> %{coto | posted_in: CotonomaService.update_on_post(posted_in, coto)}
    end
  end

  def repost!(%Coto{} = coto, %Amishi{} = amishi),
    do: do_repost!(coto, amishi, nil)

  def repost!(%Coto{} = coto, %Amishi{} = amishi, %Cotonoma{id: cotonoma_id}),
    do: do_repost!(coto, amishi, cotonoma_id)

  defp do_repost!(coto, amishi, cotonoma_id) do
    coto =
      coto
      |> Repo.preload(@preload_repost)
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
              coto |> complement(amishi)

            cotonoma_id ->
              coto =
                coto
                |> change(reposted_in_ids: [cotonoma_id | coto.reposted_in_ids])
                |> Repo.update!()
                |> complement(amishi)

              CotoGraphService.sync(Bolt.Sips.conn(), coto)
              coto
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

  def delete!(id, %Amishi{} = amishi) do
    {:ok, coto} =
      Repo.transaction(fn ->
        coto = get_by_amishi!(id, amishi)

        repost =
          if coto.repost && coto.posted_in do
            # update reposted_in_ids if the coto is a repost
            repost =
              coto.repost
              |> change(
                reposted_in_ids:
                  coto.repost.reposted_in_ids
                  |> List.delete(coto.posted_in.id)
              )
              |> Repo.update!()
              |> complement(amishi)

            CotoGraphService.sync(Bolt.Sips.conn(), repost)
            repost
          else
            coto.repost
          end

        if coto.cotonoma do
          case CotonomaService.stats(coto.cotonoma) do
            %{cotos: 0, connections: 0} -> Repo.delete!(coto.cotonoma)
            _ -> raise InvalidOperation
          end
        end

        Repo.delete!(coto)
        CotoGraphService.delete_coto(Bolt.Sips.conn(), id)

        %{coto | repost: repost}
      end)

    coto
  end
end
