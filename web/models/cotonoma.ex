defmodule Cotoami.Cotonoma do
  @moduledoc """
  コトの間 (Cotonoma) is a space for chatting and weaving Cotos.
  """

  use Cotoami.Web, :model
  import Cotoami.Helpers
  alias Cotoami.Amishi

  @key_length 10
  @name_max_length 30

  schema "cotonomas" do
    field :key, :string
    field :name, :string
    field :pinned, :boolean
    field :timeline_revision, :integer
    field :graph_revision, :integer

    belongs_to :coto, Cotoami.Coto
    belongs_to :owner, Cotoami.Amishi

    has_many :cotos, Cotoami.Coto

    timestamps(type: :utc_datetime)
  end

  def validate_name(changeset) do
    validate_length(changeset, :name, max: @name_max_length)
  end

  def changeset_to_insert(struct, params \\ %{}) do
    struct
    |> cast(params, [:name, :coto_id, :owner_id])
    |> generate_key
    |> validate_required([:key, :name, :coto_id, :owner_id])
    |> validate_name()
  end

  def changeset_to_update_name(struct, params \\ %{}) do
    struct
    |> cast(params, [:name])
    |> validate_required([:name])
    |> validate_name()
  end

  def changeset_to_import(
    struct,
    %{"as_cotonoma" => true} = coto_json,
    %Amishi{id: amishi_id}
  ) do
    data = %{
      id: coto_json["cotonoma_id"],
      key: coto_json["cotonoma_key"],
      name: coto_json["content"],
      coto_id: coto_json["id"],
      owner_id: amishi_id,
      inserted_at: unixtime_to_datetime!(coto_json["inserted_at"]),
      updated_at: unixtime_to_datetime!(coto_json["updated_at"])
    }
    struct
    |> cast(data, Map.keys(data))
    |> validate_required([:id, :key, :name, :coto_id, :owner_id])
    |> validate_name()
  end

  defp generate_key(changeset) do
    key =
      @key_length
      |> :crypto.strong_rand_bytes()
      |> Base.hex_encode32(case: :lower)
    changeset |> put_change(:key, key)
  end

  def in_cotonoma(query, nil), do: query
  def in_cotonoma(query, cotonoma_id) do
    from c in query,
      join: coto in assoc(c, :coto),
      where: coto.posted_in_id == ^cotonoma_id
  end
end
