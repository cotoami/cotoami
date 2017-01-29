defmodule Cotoami.Cotonoma do
  @moduledoc """
  コトの間 (Cotonoma) is a space for chatting and weaving Cotos.
  """
  
  use Cotoami.Web, :model
  
  @key_length 10

  schema "cotonomas" do
    field :key, :string
    field :name, :string
    belongs_to :coto, Cotoami.Coto
    belongs_to :owner, Cotoami.Owner
    has_many :cotos, Cotoami.Coto

    timestamps()
  end

  def changeset_new(struct, params \\ %{}) do
    struct
    |> cast(params, [:name, :coto_id, :owner_id])
    |> generate_key
    |> validate_required([:key, :name, :coto_id, :owner_id])
  end
  
  defp generate_key(changeset) do
    key = :crypto.strong_rand_bytes(@key_length) |> Base.hex_encode32(case: :lower)
    changeset |> put_change(:key, key)
  end
end
