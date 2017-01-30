defmodule Cotoami.CotoService do
  require Logger
  import Ecto.Query, only: [preload: 2]
  alias Cotoami.Repo
  alias Cotoami.Coto
  
  def create!(cotonoma_id, amishi_id, content) do
    # TODO: check the permission for cotonoma
    Coto.changeset(%Coto{}, %{
      posted_in_id: cotonoma_id,
      amishi_id: amishi_id,
      content: content,
      as_cotonoma: false
    }) 
    |> Repo.insert!
  end
  
  def get_cotos_by_amishi(amishi_id) do
    Coto 
    |> Coto.for_amishi(amishi_id)
    |> preload([:posted_in, :cotonoma])
    |> Repo.all
  end
end
