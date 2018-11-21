defmodule Cotoami.Watch do
  @moduledoc """
  A watch is an entry of watchlist.
  """

  use Ecto.Schema

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "watchlist" do
    belongs_to(:amishi, Cotoami.Amishi)
    belongs_to(:cotonoma, Cotoami.Cotonoma)
    field(:last_post_timestamp, :utc_datetime)

    timestamps(type: :utc_datetime)
  end
end
