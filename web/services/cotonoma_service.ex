defmodule Cotoami.CotonomaService do
  require Logger
  import Ecto.Query, only: [preload: 2]
  alias Cotoami.Repo
  alias Cotoami.Coto
  alias Cotoami.Cotonoma
  
  def create!(cotonoma_id, amishi_id, name) do
    # TODO: check cotonoma membership
    {:ok, {coto, cotonoma}} =
      Repo.transaction(fn ->
        coto = 
          Coto.changeset(%Coto{}, %{
            posted_in_id: cotonoma_id,
            amishi_id: amishi_id,
            content: name,
            as_cotonoma: true
          }) 
          |> Repo.insert!
          
        cotonoma =
          Cotonoma.changeset_new(%Cotonoma{}, %{
            name: name,
            coto_id: coto.id,
            owner_id: amishi_id
          })
          |> Repo.insert!
          
        {coto, cotonoma}
      end)
    {coto, cotonoma}
  end
  
  def get_by_key(key, amishi_id) do
    Cotonoma
    |> Cotonoma.for_amishi(amishi_id)
    |> Repo.get_by(key: key)
  end
  
  def get_cotos(key, amishi_id) do
    case get_by_key(key, amishi_id) do
      nil -> nil
      cotonoma ->
        cotos =
          Coto 
          |> Coto.in_cotonoma(cotonoma.id)
          |> preload(:cotonoma)
          |> Repo.all
        {cotonoma, cotos}
    end
  end
end
