defmodule Cotoami.Coto do
  @moduledoc """
  コト (Coto) is a post by an Amishi.
  """
  
  use Cotoami.Web, :model

  schema "cotos" do
    field :content, :string
    belongs_to :amishi, Cotoami.Amishi
    has_one :cotonoma, Cotoami.Cotonoma

    timestamps()
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:content])
    |> validate_required([:content])
  end
end
