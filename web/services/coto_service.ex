defmodule Cotoami.CotoService do
  @moduledoc """
  Provides Coto related functions.
  """

  require Logger
  import Ecto.Query
  alias Cotoami.{Repo, Coto, Amishi, CotonomaService, CotoGraphService}
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

  def get_cotos_by_amishi(amishi_id) do
    Coto
    |> Coto.for_amishi(amishi_id)
    |> preload([:amishi, :posted_in, :cotonoma])
    |> limit(100)
    |> Repo.all
  end

  def create!(cotonoma_id_nillable, amishi_id, content) do
    posted_in =
      CotonomaService.check_permission!(
        cotonoma_id_nillable, amishi_id)
    coto =
      %Coto{}
      |> Coto.changeset_to_insert(%{
          posted_in_id: cotonoma_id_nillable,
          amishi_id: amishi_id,
          content: content,
          as_cotonoma: false
        })
      |> Repo.insert!
    {coto, posted_in}
  end

  def update_content!(id, %{content: _} = params, %Amishi{id: amishi_id}) do
    Repo.transaction(fn ->
      Coto
      |> Coto.for_amishi(amishi_id)
      |> Repo.get!(id)
      |> Coto.changeset_to_update_content(params)
      |> Repo.update!()

      CotoGraphService.sync_coto_props!(Bolt.Sips.conn, get(id))
    end)
  end

  def delete!(id, %Amishi{id: amishi_id}) do
    Repo.transaction(fn ->
      Coto
      |> Coto.for_amishi(amishi_id)
      |> Repo.get!(id)
      |> ensure_not_to_be_cotonoma()
      |> Repo.delete!()

      CotoGraphService.delete_coto!(Bolt.Sips.conn, id)
    end)
  end

  defp ensure_not_to_be_cotonoma(coto) do
    if coto.as_cotonoma do
      raise InvalidOperation
    else
      coto
    end
  end
end
