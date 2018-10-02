defmodule Cotoami.Amishi do
  @moduledoc """
  編み師 (Amishi) is a person who weaves Cotos into networks.
  """

  use Ecto.Schema
  import Ecto.Changeset
  alias Cotoami.{Amishi, ExternalUser, EmailUser}

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "amishis" do
    # For email authentication only
    field :email, :string

    # For OAuth
    field :auth_provider, :string
    field :auth_id, :string

    field :name, :string
    field :avatar_url, :string

    field :disabled, :boolean
    field :invite_limit, :integer

    belongs_to :inviter, Amishi

    timestamps(type: :utc_datetime)
  end

  def changeset_to_insert(%EmailUser{} = user) do
    %Amishi{}
    |> cast(
        Map.from_struct(user), 
        [:email, :name, :avatar_url]
      )
    |> validate_required([:email])
  end
  def changeset_to_insert(%ExternalUser{} = user) do
    %Amishi{}
    |> cast(
        Map.from_struct(user), 
        [:auth_provider, :auth_id, :name, :avatar_url]
      )
    |> validate_required([:auth_provider, :auth_id])
  end

  def changeset_to_update(%Amishi{} = amishi, %EmailUser{} = user) do
    amishi |> cast(Map.from_struct(user), [:name, :avatar_url])
  end
  def changeset_to_update(%Amishi{} = amishi, %ExternalUser{} = user) do
    amishi |> cast(Map.from_struct(user), [:name, :avatar_url])
  end
end
