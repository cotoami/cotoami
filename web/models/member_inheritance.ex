defmodule Cotoami.MemberInheritance do
  use Cotoami.Web, :model

  schema "member_inheritances" do
    belongs_to :from, Cotoami.Cotonoma
    belongs_to :to, Cotoami.Cotonoma

    timestamps(type: :utc_datetime)
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:from_id, :to_id])
    |> validate_required([:from_id, :to_id])
  end
end
