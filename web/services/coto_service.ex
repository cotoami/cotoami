defmodule Cotoami.CotoService do
  @moduledoc """
  Provides Coto related functions.
  """

  require Logger
  import Ecto.Query, only: [from: 2, preload: 2, limit: 2]
  alias Cotoami.{Repo, Coto, Amishi, CotonomaService, CotoGraphService}
  alias Cotoami.Exceptions.UnsupportedOperation

  def get(id) do
    Coto
    |> preload([:amishi, :posted_in, :cotonoma])
    |> Repo.get(id)
  end

  def get_by_ids(coto_ids) do
    (from c in Coto, where: c.id in ^coto_ids)
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
      |> Coto.changeset(%{
          posted_in_id: cotonoma_id_nillable,
          amishi_id: amishi_id,
          content: content,
          as_cotonoma: false
        })
      |> Repo.insert!
    {coto, posted_in}
  end

  def delete!(id, %Amishi{id: amishi_id}) do
    Repo.transaction(fn ->
      Coto
      |> Coto.for_amishi(amishi_id)
      |> Repo.get!(id)
      |> ensure_not_to_be_cotonoma()
      |> Repo.delete!()

      CotoGraphService.delete_coto(id)
    end)
  end

  defp ensure_not_to_be_cotonoma(coto) do
    if coto.as_cotonoma do
      raise UnsupportedOperation
    else
      coto
    end
  end
end
