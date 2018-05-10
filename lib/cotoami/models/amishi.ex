defmodule Cotoami.Amishi do
  @moduledoc """
  編み師 (Amishi) is a person who weaves Cotos into networks.
  """

  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "amishis" do
    field :email, :string

    timestamps(type: :utc_datetime)
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:email])
    |> validate_required([:email])
  end
end
