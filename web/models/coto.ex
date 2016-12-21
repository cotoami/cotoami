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

    timestamps()
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:posted_in_id, :amishi_id, :content, :as_cotonoma])
    |> validate_required([:posted_in_id, :amishi_id, :content])
  end
end
