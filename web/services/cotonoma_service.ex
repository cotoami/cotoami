defmodule Cotoami.CotonomaService do
  require Logger
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
end
