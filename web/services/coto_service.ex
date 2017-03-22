defmodule Cotoami.CotoService do
  require Logger
  import Ecto.Query, only: [preload: 2, limit: 2]
  alias Cotoami.Repo
  alias Cotoami.Coto
  alias Cotoami.CotonomaService
  
  def create!(cotonoma_id_nillable, amishi_id, content) do
    cotonoma = 
      CotonomaService.check_permission!(
        cotonoma_id_nillable, amishi_id)
    coto = 
      Coto.changeset(%Coto{}, %{
        posted_in_id: cotonoma_id_nillable,
        amishi_id: amishi_id,
        content: content,
        as_cotonoma: false
      }) 
      |> Repo.insert!
    {coto, cotonoma}
  end
  
  def get_cotos_by_amishi(amishi_id) do
    Coto 
    |> Coto.for_amishi(amishi_id)
    |> preload([:amishi, :posted_in, :cotonoma])
    |> limit(100)
    |> Repo.all
  end
end
