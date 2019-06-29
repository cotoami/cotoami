defmodule Cotoami.CotonomaService do
  @moduledoc """
  Provides Cotonoma related functions.
  """

  require Logger
  import Ecto.Changeset, only: [change: 2]
  import Ecto.Query, warn: false

  alias Cotoami.{
    Repo,
    Coto,
    Cotonoma,
    Amishi,
    AmishiService,
    CotoService,
    CotoGraphService
  }

  def global_cotonomas_holder do
    :cotoami
    |> Application.get_env(__MODULE__, [])
    |> Keyword.get(:global_cotonomas_holder)
  end

  def create!(name, shared, %Amishi{} = amishi),
    do: do_create!(name, shared, amishi, nil)

  def create!(name, shared, %Amishi{} = amishi, %Cotonoma{id: cotonoma_id}),
    do: do_create!(name, shared, amishi, cotonoma_id)

  defp do_create!(name, shared, %Amishi{} = amishi, cotonoma_id) do
    {:ok, coto} =
      Repo.transaction(fn ->
        # create a coto
        coto =
          Coto.changeset_to_insert(%{
            content: name,
            as_cotonoma: true,
            posted_in_id: cotonoma_id,
            amishi_id: amishi.id
          })
          |> Repo.insert!()

        # create a cotonoma
        cotonoma = create_cotonoma!(coto, name, amishi.id, shared)

        %{coto | cotonoma: %{cotonoma | owner: amishi, coto: coto}}
        |> CotoService.on_created()
      end)

    %{coto | amishi: amishi, repost: nil}
  end

  defp create_cotonoma!(%Coto{as_cotonoma: true} = coto, name, amishi_id, shared) do
    %Cotonoma{}
    |> Cotonoma.changeset_to_insert(%{
      name: name,
      coto_id: coto.id,
      owner_id: amishi_id,
      shared: shared
    })
    |> Repo.insert!()
  end

  def cotonomatize!(%Coto{as_cotonoma: false} = coto, %Amishi{} = amishi, name \\ nil) do
    cotonoma_name = name || coto.content

    cotonoma_coto =
      coto
      |> change(as_cotonoma: true)
      |> change(content: cotonoma_name)
      |> Repo.update!()

    shared =
      case coto.posted_in do
        nil -> false
        posted_in -> posted_in.shared
      end

    cotonoma = create_cotonoma!(cotonoma_coto, cotonoma_name, amishi.id, shared)

    cotonoma_coto = %{
      cotonoma_coto
      | amishi: amishi,
        posted_in: Repo.preload(coto.posted_in, :owner),
        cotonoma: %{cotonoma | owner: amishi, coto: cotonoma_coto}
    }

    CotoGraphService.sync(Bolt.Sips.conn(), cotonoma_coto)

    cotonoma_coto
  end

  def get!(id, %Amishi{} = amishi) do
    Cotonoma
    |> preload([:coto, :owner])
    |> Repo.get(id)
    |> check_permission!(amishi)
  end

  def get_by_key!(key, %Amishi{} = amishi) do
    Cotonoma
    |> preload([:coto, :owner])
    |> Repo.get_by(key: key)
    |> check_permission!(amishi)
  end

  defp check_permission!(cotonoma, amishi) do
    case cotonoma do
      nil ->
        raise Cotoami.Exceptions.NotFound

      cotonoma ->
        Cotonoma.ensure_accessible_by(cotonoma, amishi)
        cotonoma
    end
  end

  def get_by_name(name, %Amishi{id: amishi_id}) do
    Cotonoma
    |> preload([:coto, :owner])
    |> Repo.get_by(name: name, owner_id: amishi_id)
  end

  def all_by_ids(ids) do
    from(c in Cotonoma, where: c.id in ^ids)
    |> preload([:coto, :owner])
    |> Repo.all()
  end

  def all_by_ids(ids, %Amishi{} = amishi) do
    all_by_ids(ids)
    |> Enum.filter(&Cotonoma.accessible_by?(&1, amishi))
  end

  def all_by_keys(keys) do
    from(c in Cotonoma, where: c.key in ^keys)
    |> preload([:coto, :owner])
    |> Repo.all()
  end

  def map_by_ids(ids) do
    from(c in Cotonoma, where: c.id in ^ids, select: {c.id, c})
    |> preload([:coto, :owner])
    |> Repo.all()
    |> Map.new()
  end

  def map_by_ids(ids, %Amishi{} = amishi) do
    map_by_ids(ids)
    |> Enum.filter(fn {_, c} -> Cotonoma.accessible_by?(c, amishi) end)
    |> Map.new()
  end

  def map_by_keys(keys) do
    from(c in Cotonoma, where: c.key in ^keys, select: {c.key, c})
    |> preload([:coto, :owner])
    |> Repo.all()
    |> Map.new()
  end

  def recent_cotonomas(%Amishi{id: amishi_id} = amishi) do
    Cotonoma
    |> where([c], c.owner_id == ^amishi_id)
    |> limit(100)
    |> do_query_for_cotonomas(amishi)
  end

  def sub_cotonomas(cotonoma_id, %Amishi{} = amishi) do
    Cotonoma
    |> Cotonoma.in_cotonoma(cotonoma_id)
    |> limit(100)
    |> do_query_for_cotonomas(amishi)
  end

  defp do_query_for_cotonomas(query, amishi) do
    query
    |> preload(coto: [:posted_in], owner: [])
    |> order_by(desc: :updated_at)
    |> Repo.all()
    |> set_reposted_in(amishi)
  end

  def suggest(%Amishi{id: amishi_id}, query) do
    from(c in Cotonoma, where: c.owner_id == ^amishi_id and ilike(c.name, ^"%#{query}%"))
    |> preload([:owner])
    |> order_by(desc: :updated_at)
    |> limit(10)
    |> Repo.all()
  end

  def update_on_post(%Cotonoma{} = cotonoma, %Coto{inserted_at: coto_inserted_at}) do
    cotonoma
    |> change(last_post_timestamp: coto_inserted_at)
    |> change(timeline_revision: cotonoma.timeline_revision + 1)
    |> Repo.update!()
    |> Cotonoma.copy_associations(cotonoma)
  end

  def increment_timeline_revision(%Cotonoma{} = cotonoma) do
    cotonoma
    |> change(timeline_revision: cotonoma.timeline_revision + 1)
    |> Repo.update!()
    |> Cotonoma.copy_associations(cotonoma)
  end

  def increment_graph_revision(%Cotonoma{} = cotonoma) do
    cotonoma
    |> change(graph_revision: cotonoma.graph_revision + 1)
    |> Repo.update!()
    |> Cotonoma.copy_associations(cotonoma)
  end

  def stats(%Cotonoma{id: cotonoma_id, key: key} = cotonoma) do
    %{
      key: key,
      cotos:
        Coto
        |> Coto.in_cotonoma(cotonoma_id)
        |> Repo.aggregate(:count, :id),
      connections: CotoGraphService.count_connections_in_cotonoma(Bolt.Sips.conn(), cotonoma)
    }
  end

  def global_cotonomas do
    case global_cotonomas_holder_amishi() do
      nil ->
        []

      amishi ->
        keys = CotoGraphService.pinned_cotonoma_keys(Bolt.Sips.conn(), amishi)
        cotonomas = map_by_keys(keys)
        for key <- keys, cotonomas[key], do: cotonomas[key]
    end
  end

  defp global_cotonomas_holder_amishi do
    case global_cotonomas_holder() do
      nil ->
        nil

      id_or_email ->
        case UUID.info(id_or_email) do
          {:ok, _info} ->
            AmishiService.get(id_or_email)

          {:error, _reason} ->
            AmishiService.get_by_email(id_or_email)
        end
    end
  end

  defp set_reposted_in(cotonomas, %Amishi{} = amishi) when is_list(cotonomas) do
    all_reposted_cotonomas =
      cotonomas
      |> Enum.map(& &1.coto.reposted_in_ids)
      |> List.flatten()
      |> Enum.uniq()
      |> map_by_ids(amishi)

    cotonomas
    |> Enum.map(fn cotonoma ->
      reposted_in =
        cotonoma.coto.reposted_in_ids
        |> Enum.map(&all_reposted_cotonomas[&1])
        |> Enum.filter(& &1)

      Map.put(cotonoma, :reposted_in, reposted_in)
    end)
  end
end
