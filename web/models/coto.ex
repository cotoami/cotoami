defmodule Cotoami.Coto do
  @moduledoc """
  コト (Coto) is a post by an Amishi.
  """

  use Cotoami.Web, :model

  schema "cotos" do
    field :content, :string
    field :as_cotonoma, :boolean
    belongs_to :posted_in, Cotoami.Cotonoma
    belongs_to :amishi, Cotoami.Amishi
    has_one :cotonoma, Cotoami.Cotonoma

    timestamps(type: :utc_datetime)
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:posted_in_id, :amishi_id, :content, :as_cotonoma])
    |> validate_required([:amishi_id, :content])
  end

  def for_amishi(query, amishi_id) do
    from c in query,
      where: c.amishi_id == ^amishi_id,
      order_by: [desc: c.inserted_at]
  end

  def in_cotonoma(query, cotonoma_id) do
    from c in query,
      where: c.posted_in_id == ^cotonoma_id,
      order_by: [desc: c.inserted_at]
  end
end
