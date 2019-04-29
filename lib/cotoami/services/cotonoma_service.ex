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
    CotonomaService,
    CotoGraphService,
    Exceptions.NotFound
  }

  def global_cotonomas_holder do
    :cotoami
    |> Application.get_env(__MODULE__, [])
    |> Keyword.get(:global_cotonomas_holder)
  end

  def create!(%Amishi{} = amishi, name, shared, cotonoma_id \\ nil) do
    {:ok, coto} =
      Repo.transaction(fn ->
        # create a coto
        coto =
          %Coto{}
          |> Coto.changeset_to_insert(%{
            content: name,
            as_cotonoma: true,
            posted_in_id: cotonoma_id,
            amishi_id: amishi.id
          })
          |> Repo.insert!()

        # create a cotonoma
        cotonoma = create_cotonoma!(coto, name, amishi.id, shared)
        coto = %{coto | cotonoma: %{cotonoma | owner: amishi, coto: coto}}

        # set last_post_timestamp and timeline_revision to the posted_in cotonoma
        case get!(cotonoma_id) do
          nil ->
            %{coto | posted_in: nil}

          posted_in ->
            %{coto | posted_in: CotonomaService.on_post(posted_in, coto)}
        end
      end)

    %{coto | amishi: amishi}
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
        posted_in: complement_owner(coto.posted_in),
        cotonoma: %{cotonoma | owner: amishi, coto: cotonoma_coto}
    }

    CotoGraphService.sync(Bolt.Sips.conn(), cotonoma_coto)

    cotonoma_coto
  end

  def get(id) do
    Cotonoma
    |> preload([:coto, :owner])
    |> Repo.get(id)
    |> complement_owner()
  end

  def get!(nil), do: nil

  def get!(id) do
    case get(id) do
      nil -> raise NotFound, "cotonoma: id<#{id}>"
      cotonoma -> cotonoma
    end
  end

  def get_by_key(key) do
    Cotonoma
    |> preload([:coto, :owner])
    |> Repo.get_by(key: key)
    |> complement_owner()
  end

  def get_by_key!(nil), do: nil

  def get_by_key!(key) do
    case get_by_key(key) do
      nil -> raise NotFound, "cotonoma: key<#{key}>"
      cotonoma -> cotonoma
    end
  end

  def keys_map(keys) do
    from(c in Cotonoma, where: c.key in ^keys, select: {c.key, c})
    |> preload([:coto, :owner])
    |> Repo.all()
    |> Map.new()
  end

  def complement_owner(nil), do: nil

  def complement_owner(%Cotonoma{} = cotonoma) do
    case cotonoma.owner do
      %Ecto.Association.NotLoaded{} ->
        %{cotonoma | owner: AmishiService.get(cotonoma.owner_id)}

      _owner ->
        cotonoma
    end
  end

  def recent_cotonomas(%Amishi{id: amishi_id}) do
    Cotonoma
    |> where([c], c.owner_id == ^amishi_id)
    |> limit(100)
    |> do_query_for_cotonomas()
  end

  def sub_cotonomas(cotonoma_id) do
    Cotonoma
    |> Cotonoma.in_cotonoma(cotonoma_id)
    |> limit(100)
    |> do_query_for_cotonomas()
  end

  defp do_query_for_cotonomas(query) do
    query
    |> preload([:coto, :owner])
    |> order_by(desc: :updated_at)
    |> Repo.all()
  end

  def on_post(%Cotonoma{} = cotonoma, %Coto{inserted_at: coto_inserted_at}) do
    cotonoma
    |> change(last_post_timestamp: coto_inserted_at)
    |> change(timeline_revision: cotonoma.timeline_revision + 1)
    |> Repo.update!()
    |> Cotonoma.copy_belongings(cotonoma)
  end

  def increment_timeline_revision(%Cotonoma{} = cotonoma) do
    cotonoma
    |> change(timeline_revision: cotonoma.timeline_revision + 1)
    |> Repo.update!()
    |> Cotonoma.copy_belongings(cotonoma)
  end

  def increment_graph_revision(%Cotonoma{} = cotonoma) do
    cotonoma
    |> change(graph_revision: cotonoma.graph_revision + 1)
    |> Repo.update!()
    |> Cotonoma.copy_belongings(cotonoma)
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
        cotonomas = keys_map(keys)
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
end
