defmodule Cotoami.Cotonoma do
  @moduledoc """
  コトの間 (Cotonoma) is a space for chatting and weaving Cotos.
  """

  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query, warn: false
  import Cotoami.Helpers
  alias Cotoami.{Amishi, Cotonoma}

  @key_length 10
  @name_max_length 50

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "cotonomas" do
    field :key, :string
    field :name, :string
    field :shared, :boolean
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
    |> cast(params, [:name, :coto_id, :owner_id, :shared])
    |> generate_key()
    |> put_change(:pinned, false)
    |> put_change(:timeline_revision, 0)
    |> put_change(:graph_revision, 0)
    |> validate_required([:key, :name, :coto_id, :owner_id, :shared])
    |> validate_name()
  end

  def changeset_to_update(struct, params \\ %{}) do
    struct
    |> cast(params, [:name, :shared])
    |> validate_required([:name, :shared])
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
      pinned: coto_json["cotonoma_pinned"],
      timeline_revision: coto_json["cotonoma_timeline_rev"],
      graph_revision: coto_json["cotonoma_graph_rev"],
      coto_id: coto_json["id"],
      owner_id: amishi_id,
      inserted_at: unixtime_to_datetime!(coto_json["cotonoma_inserted_at"] || coto_json["inserted_at"]),
      updated_at: unixtime_to_datetime!(coto_json["cotonoma_updated_at"] || coto_json["updated_at"])
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

  def in_cotonoma(query, cotonoma_id) do
    from c in query,
      join: coto in assoc(c, :coto),
      where: coto.posted_in_id == ^cotonoma_id
  end

  def copy_belongings(%__MODULE__{} = target, %__MODULE__{} = from) do
    %{target | coto: from.coto, owner: from.owner}
  end

  def accessible_by?(%Cotonoma{owner: owner, shared: shared}, %Amishi{id: amishi_id}) do
    owner.id == amishi_id or shared
  end

  def ensure_accessible_by(%Cotonoma{} = cotonoma, %Amishi{} = amishi) do
    unless accessible_by?(cotonoma, amishi) do
      raise Cotoami.Exceptions.NoPermission
    end
  end
end
