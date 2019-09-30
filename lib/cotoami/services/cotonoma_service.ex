defmodule Cotoami.CotonomaService do
  @moduledoc """
  Provides Cotonoma related functions.
  """

  require Logger
  import Ecto.Changeset, only: [change: 2]
  import Ecto.Query, warn: false

  alias Cotoami.Repo
  alias Cotoami.Amishi
  alias Cotoami.Coto
  alias Cotoami.Cotonoma
  alias Cotoami.CotoService
  alias Cotoami.CotoGraphService

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

  def get_accessible!(id, %Amishi{} = amishi) do
    Cotonoma
    |> preload([:coto, :owner])
    |> Repo.get(id)
    |> check_permission!(amishi)
  end

  def get_accessible_by_key!(key, %Amishi{} = amishi) do
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

  def get_accessible_by_key_or_name(key_or_name, %Amishi{} = amishi) do
    if Cotonoma.is_possibly_key(key_or_name) do
      get_accessible_by_key!(key_or_name, amishi)
    else
      get_by_name(key_or_name, amishi)
    end
  rescue
    _ in Cotoami.Exceptions.NotFound -> get_by_name(key_or_name, amishi)
  end

  def all_by_ids(ids) do
    from(c in Cotonoma, where: c.id in ^ids)
    |> preload([:coto, :owner])
    |> Repo.all()
  end

  def accessibles_by_ids(ids, %Amishi{} = amishi) do
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

  def accessible_map_by_ids(ids, %Amishi{} = amishi) do
    map_by_ids(ids)
    |> Enum.filter(fn {_, c} -> Cotonoma.accessible_by?(c, amishi) end)
    |> Map.new()
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

  def update_on_delete(
        %Cotonoma{id: cotonoma_id} = cotonoma,
        %Coto{inserted_at: coto_inserted_at}
      ) do
    # last_post_timestamp should be updated if the deleted coto is the last post.
    last_post_timestamp =
      case DateTime.compare(coto_inserted_at, cotonoma.last_post_timestamp) do
        :lt ->
          cotonoma.last_post_timestamp

        _ ->
          from(c in Coto,
            where: c.posted_in_id == ^cotonoma_id,
            select: max(c.inserted_at)
          )
          |> Repo.one()
      end

    cotonoma
    |> change(last_post_timestamp: last_post_timestamp)
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
end
