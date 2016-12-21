defmodule Cotoami.CotoService do
  require Logger
  alias Cotoami.Repo
  alias Cotoami.Coto
  
  def create!(cotonoma_id, amishi_id, content) do
    Coto.changeset(%Coto{}, %{
      posted_in_id: cotonoma_id,
      amishi_id: amishi_id,
      content: content
    }) 
    |> Repo.insert!
  end
end
