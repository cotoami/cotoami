defmodule Cotoami.CotonomaService do
  @moduledoc """
  Provides Cotonoma related functions.
  """

  require Logger
  import Ecto.Query, only: [preload: 2, limit: 2, order_by: 2]
  import Ecto.Changeset, only: [change: 2]
  alias Cotoami.{Repo, Coto, Cotonoma, Amishi, AmishiService, CotoService}

  def create!(name, amishi_id, cotonoma_id \\ nil) do
    posted_in =
      case cotonoma_id do
        nil -> nil
        cotonoma_id -> Repo.get!(Cotonoma, cotonoma_id)
      end

    coto =
      %Coto{}
      |> Coto.changeset_to_insert(%{
          posted_in_id: cotonoma_id,
          amishi_id: amishi_id,
          content: name,
          as_cotonoma: true
        })
      |> Repo.insert!

    cotonoma =
      %Cotonoma{}
      |> Cotonoma.changeset_to_insert(%{
          name: name,
          coto_id: coto.id,
          owner_id: amishi_id
        })
      |> Repo.insert!

    cotonoma = %{cotonoma | coto: coto}
    coto = %{coto | cotonoma: cotonoma}

    {{coto, cotonoma}, posted_in}
  end

  def get(id) do
    Cotonoma
    |> preload([:coto, :owner])
    |> Repo.get(id)
    |> complement_owner()
  end

  def get_by_key(key) do
    Cotonoma
    |> preload([:coto, :owner])
    |> Repo.get_by(key: key)
    |> complement_owner()
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

  def recent_cotonoma(cotonoma_id \\ nil) do
    Cotonoma
    |> preload([:coto, :owner])
    |> Cotonoma.in_cotonoma(cotonoma_id)
    |> order_by(desc: :updated_at)
    |> limit(100)
    |> Repo.all()
    |> Enum.map(&complement_owner(&1))
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
  end

  def increment_graph_revision(%Cotonoma{} = cotonoma) do
    cotonoma
    |> change(graph_revision: cotonoma.graph_revision + 1)
    |> Repo.update!()
  end
end
