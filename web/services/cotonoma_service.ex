defmodule Cotoami.CotonomaService do
  @moduledoc """
  Provides Cotonoma related functions.
  """

  require Logger
  import Ecto.Query, only: [preload: 2, where: 3, limit: 2, order_by: 2]
  import Ecto.Changeset, only: [change: 2]
  alias Cotoami.{Repo, Coto, Cotonoma, Amishi, AmishiService, CotoService}

  def create!(cotonoma_id_nillable, amishi_id, name) do
    posted_in = check_permission!(cotonoma_id_nillable, amishi_id)
    {:ok, {coto, cotonoma}} =
      Repo.transaction(fn ->
        coto =
          %Coto{}
          |> Coto.changeset_to_insert(%{
              posted_in_id: cotonoma_id_nillable,
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

        {coto, cotonoma}
      end)
    {{coto, cotonoma}, posted_in}
  end

  def get(id, amishi_id) do
    Cotonoma
    |> preload([:coto, :owner])
    |> Repo.get(id)
    |> complement_owner()
  end

  def get_by_key(key, amishi_id) do
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

  def check_permission!(nil, _amishi_id), do: nil
  def check_permission!(cotonoma_id, amishi_id) do
    case check_permission(cotonoma_id, amishi_id) do
      nil -> raise "Forbidden cotonoma: #{cotonoma_id}"
      cotonoma -> cotonoma
    end
  end

  def check_permission(cotonoma_id, amishi_id) do
    Cotonoma
    |> where([c], c.id == ^cotonoma_id)
    |> Repo.one()
  end

  def find_by_amishi(amishi_id, cotonoma_id_nillable) do
    Cotonoma
    |> preload([:coto, :owner])
    |> Cotonoma.in_cotonoma_if_specified(cotonoma_id_nillable)
    |> order_by(desc: :updated_at)
    |> limit(100)
    |> Repo.all()
    |> Enum.map(&complement_owner(&1))
  end

  def get_cotos(key, %Amishi{id: amishi_id} = amishi) do
    case get_by_key(key, amishi_id) do
      nil -> nil
      cotonoma ->
        if check_permission(cotonoma.id, amishi_id) do
          cotos =
            Coto
            |> Coto.in_cotonoma(cotonoma.id)
            |> preload([:amishi, :posted_in, :cotonoma])
            |> limit(100)
            |> Repo.all
            |> Enum.map(&(CotoService.complement_amishi(&1, amishi)))
          {cotos, cotonoma}
        else
          nil
        end
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
