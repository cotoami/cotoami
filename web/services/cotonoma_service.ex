defmodule Cotoami.CotonomaService do
  require Logger
  alias Cotoami.Repo
  alias Cotoami.Cotonoma
  
  def get_or_create_home!(amishi_id) do
    case Cotonoma.query_home(amishi_id) |> Repo.one do
      nil ->
        Cotonoma.changeset_new(%Cotonoma{}, %{owner_id: amishi_id})
        |> Repo.insert!
      home -> home
    end
  end
end
