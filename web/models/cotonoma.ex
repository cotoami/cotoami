defmodule Cotoami.Cotonoma do
  @moduledoc """
  コトの間 (Cotonoma) is a space for chatting and weaving Cotos.
  """
  
  use Cotoami.Web, :model

  schema "cotonomas" do
    field :key, :string
    field :name, :string
    belongs_to :coto, Cotoami.Coto
    belongs_to :owner, Cotoami.Owner

    timestamps()
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:key, :name])
    |> validate_required([:key, :name])
  end
end
