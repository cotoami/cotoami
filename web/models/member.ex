defmodule Cotoami.Member do
  use Cotoami.Web, :model

  schema "members" do
    field :email, :string
    belongs_to :cotonoma, Cotoami.Cotonoma
    belongs_to :amishi, Cotoami.Amishi

    timestamps()
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:email, :cotonoma_id, :amishi_id])
    |> validate_required([:email, :cotonoma_id])
  end
  
  def for_cotonoma(query, cotonoma_id) do
    from m in query, 
      where: m.cotonoma_id == ^cotonoma_id,
      order_by: [desc: m.inserted_at]
  end
end
