defmodule Cotoami.Amishi do
  @moduledoc """
  編み師 (Amishi) is a person who weaves cotos into networks.
  """

  use Cotoami.Web, :model

  schema "amishis" do
    field :email, :string

    timestamps()
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:email])
    |> validate_required([:email])
  end
end
