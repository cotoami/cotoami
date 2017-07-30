defmodule Cotoami.CotoService do
  @moduledoc """
  Provides Coto related functions.
  """

  require Logger
  import Ecto.Query, only: [preload: 2, limit: 2]
  alias Cotoami.{Repo, Coto, CotonomaService}

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

  def get_cotos_by_amishi(amishi_id) do
    Coto
    |> Coto.for_amishi(amishi_id)
    |> preload([:amishi, :posted_in, :cotonoma])
    |> limit(100)
    |> Repo.all
  end
end
