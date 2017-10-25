defmodule Cotoami.CotonomaService do
  @moduledoc """
  Provides Cotonoma related functions.
  """

  require Logger
  import Ecto.Query, only: [preload: 2, where: 3, limit: 2, order_by: 2]
  import Ecto.Changeset, only: [change: 2]
  alias Cotoami.{
    Repo, Coto, Cotonoma, Amishi,
    AmishiService, CotoService, CotoGraphService
  }
  alias Cotoami.Exceptions.NotFound

  def create!(name, %Amishi{} = amishi, cotonoma_id \\ nil) do
    posted_in = get!(cotonoma_id)

    cotonoma_coto =
      %Coto{}
      |> Coto.changeset_to_insert(%{
          posted_in_id: cotonoma_id,
          amishi_id: amishi.id,
          content: name,
          as_cotonoma: true
        })
      |> Repo.insert!()

    cotonoma = create_cotonoma!(cotonoma_coto, name, amishi.id)

    cotonoma_coto = %{cotonoma_coto |
      amishi: amishi,
      posted_in: posted_in,
      cotonoma: %{cotonoma |
        owner: amishi,
        coto: cotonoma_coto
      }
    }

    {cotonoma_coto, posted_in}
  end

  defp create_cotonoma!(%Coto{as_cotonoma: true} = coto, name, amishi_id) do
    %Cotonoma{}
    |> Cotonoma.changeset_to_insert(%{
        name: name,
        coto_id: coto.id,
        owner_id: amishi_id
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

    cotonoma = create_cotonoma!(cotonoma_coto, cotonoma_name, amishi.id)

    cotonoma_coto =
      %{cotonoma_coto |
        amishi: amishi,
        posted_in: coto.posted_in,
        cotonoma: %{cotonoma |
          owner: amishi,
          coto: cotonoma_coto
        }
      }

    bolt_conn = Bolt.Sips.conn

    CotoGraphService.sync_coto_props(bolt_conn, cotonoma_coto)

    # Increment the revision if it has connections, which in turn displays it
    # in the "recent cotonomas" for other amishis even if its timeline is empty.
    graph = CotoGraphService.get_subgraph(bolt_conn, cotonoma_coto.cotonoma)
    if map_size(graph.connections) > 0 do
      increment_graph_revision(cotonoma_coto.cotonoma)
    end

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

  def complement_owner(nil), do: nil
  def complement_owner(%Cotonoma{} = cotonoma) do
    case cotonoma.owner do
      %Ecto.Association.NotLoaded{} ->
        %{cotonoma | owner: AmishiService.get(cotonoma.owner_id)}
      owner ->
        %{cotonoma | owner: AmishiService.append_gravatar_profile(owner)}
    end
  end

  defp complement_owners(cotonomas) when is_list(cotonomas) do
    cotonomas
    |> Enum.map(&(&1.owner))
    |> AmishiService.append_gravatar_profiles()
    |> Enum.zip(cotonomas)
    |> Enum.map(fn({owner, cotonoma}) -> %{cotonoma | owner: owner} end)
  end

  def recent_cotonomas(%Amishi{id: amishi_id}) do
    Cotonoma
    |> Cotonoma.exclude_empty_by_others(amishi_id)
    |> limit(100)
    |> do_query_for_cotonomas()
  end

  def sub_cotonomas(cotonoma_id) do
    Cotonoma
    |> Cotonoma.in_cotonoma(cotonoma_id)
    |> limit(100)
    |> do_query_for_cotonomas()
  end

  def pinned_cotonomas() do
    Cotonoma
    |> where([c], c.pinned == true)
    |> do_query_for_cotonomas()
  end

  defp do_query_for_cotonomas(query) do
    query
    |> preload([:coto, :owner])
    |> order_by(desc: :updated_at)
    |> Repo.all()
    |> complement_owners()
  end

  def get_cotos(key, %Amishi{} = amishi) do
    case get_by_key(key) do
      nil -> nil
      cotonoma ->
        cotos =
          Coto
          |> Coto.in_cotonoma(cotonoma.id)
          |> preload([:amishi, :posted_in, :cotonoma])
          |> limit(100)
          |> Repo.all
          |> Enum.map(&(CotoService.complement_amishi(&1, amishi)))
        {cotos, cotonoma}
    end
  end

  def pin(%Cotonoma{} = cotonoma), do: set_pinned(cotonoma, true)
  def unpin(%Cotonoma{} = cotonoma), do: set_pinned(cotonoma, false)
  defp set_pinned(cotonoma, pinned) do
    cotonoma |> change(pinned: pinned) |> Repo.update!()
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
      connections:
        CotoGraphService.count_connections_in_cotonoma(Bolt.Sips.conn, cotonoma)
    }
  end
end
