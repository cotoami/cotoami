defmodule Cotoami.WatchlistService do
  @moduledoc """
  Provides watchlist related functions.
  """

  require Logger
  import Ecto.Changeset
  import Ecto.Query, warn: false
  alias Cotoami.Repo
  alias Cotoami.Amishi
  alias Cotoami.Cotonoma
  alias Cotoami.Watching

  def get_or_create!(%Amishi{id: amishi_id}, %Cotonoma{
        id: cotonoma_id,
        last_post_timestamp: last_post_timestamp,
        shared: true
      }) do
    case Repo.get_by(Watching, amishi_id: amishi_id, cotonoma_id: cotonoma_id) do
      nil ->
        %Watching{}
        |> change(
          amishi_id: amishi_id,
          cotonoma_id: cotonoma_id,
          last_post_timestamp: last_post_timestamp
        )
        |> Repo.insert!()

      watching ->
        watching
    end
  end

  def get_watchlist(%Amishi{id: amishi_id}) do
    from(
      w in Watching,
      where: w.amishi_id == ^amishi_id,
      order_by: [desc: w.updated_at]
    )
    |> preload([:cotonoma])
    |> Repo.all()
  end
end
