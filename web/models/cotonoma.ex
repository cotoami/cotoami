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
    belongs_to :owner, Cotoami.Amishi

    has_many :cotos, Cotoami.Coto
    has_many :members, Cotoami.Member

    timestamps(type: :utc_datetime)
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

  def for_amishi(query, amishi_id) do
    from c in query,
      distinct: c.id,
      left_join: m in assoc(c, :members),
      where: c.owner_id == ^amishi_id or m.amishi_id == ^amishi_id,
      order_by: [desc: c.updated_at]
  end

  def in_cotonoma_if_specified(query, cotonoma_id_nillable) do
    if cotonoma_id_nillable do
      from c in query,
        join: coto in assoc(c, :coto),
        where: coto.posted_in_id == ^cotonoma_id_nillable
    else
      query
    end
  end
end
