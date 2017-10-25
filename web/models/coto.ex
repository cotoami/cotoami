defmodule Cotoami.Coto do
  @moduledoc """
  コト (Coto) is a post by an Amishi.
  """

  use Cotoami.Web, :model
  import Cotoami.Helpers
  alias Cotoami.Amishi

  schema "cotos" do
    field :content, :string
    field :summary, :string
    field :as_cotonoma, :boolean
    belongs_to :posted_in, Cotoami.Cotonoma
    belongs_to :amishi, Cotoami.Amishi
    has_one :cotonoma, Cotoami.Cotonoma

    timestamps(type: :utc_datetime)
  end

  def changeset_to_insert(struct, params \\ %{}) do
    struct
    |> cast(params, [:posted_in_id, :amishi_id, :content, :as_cotonoma])
    |> validate_required([:amishi_id, :content])
  end

  def changeset_to_update_content(struct, params \\ %{}) do
    struct
    |> cast(params, [:content, :summary])
    |> validate_required([:content])
  end

  def changeset_to_import(struct, json, %Amishi{id: amishi_id}) do
    data = Map.merge(json, %{
      "posted_in_id" => json["posted_in"]["id"],
      "amishi_id" => amishi_id,
      "inserted_at" => unixtime_to_datetime!(json["inserted_at"]),
      "updated_at" => unixtime_to_datetime!(json["updated_at"])
    })
    struct
    |> cast(data, [
      :id,
      :content,
      :as_cotonoma,
      :posted_in_id,
      :amishi_id,
      :inserted_at,
      :updated_at
    ])
    |> validate_required([:id, :content, :amishi_id])
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
