defmodule Cotoami.WatchService do
  @moduledoc """
  Provides watchlist related functions.
  """

  require Logger
  import Ecto.Changeset
  import Ecto.Query, warn: false

  alias Cotoami.{
    Repo,
    Amishi,
    Cotonoma,
    Watch
  }

  def get_or_create!(%Amishi{id: amishi_id}, %Cotonoma{
        id: cotonoma_id,
        last_post_timestamp: last_post_timestamp,
        shared: true
      }) do
    case Repo.get_by(Watch, amishi_id: amishi_id, cotonoma_id: cotonoma_id) do
      nil ->
        %Watch{}
        |> change(
          amishi_id: amishi_id,
          cotonoma_id: cotonoma_id,
          last_post_timestamp: last_post_timestamp
        )
        |> Repo.insert!()

      watch ->
        watch
    end
  end

  def get_watchlist(%Amishi{id: amishi_id}) do
    from(
      w in Watch,
      where: w.amishi_id == ^amishi_id,
      order_by: [desc: w.updated_at]
    )
    |> preload(cotonoma: :owner)
    |> Repo.all()
  end

  def set_last_post_timestamp(%Amishi{id: amishi_id}, %Cotonoma{id: cotonoma_id}, timestamp) do
    case Repo.get_by(Watch, amishi_id: amishi_id, cotonoma_id: cotonoma_id) do
      nil ->
        nil

      watch ->
        watch
        |> change(last_post_timestamp: timestamp)
        |> Repo.update!()
    end
  end

  def delete!(%Amishi{id: amishi_id}, %Cotonoma{id: cotonoma_id}) do
    case Repo.get_by(Watch, amishi_id: amishi_id, cotonoma_id: cotonoma_id) do
      nil -> nil
      watch -> Repo.delete!(watch)
    end
  end
end
