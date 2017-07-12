defmodule Cotoami.Repo.Migrations.CreateAmishi do
  use Ecto.Migration

  def change do
    create table(:amishis, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :email, :string, null: false

      timestamps(type: :utc_datetime)
    end

    create unique_index(:amishis, [:email])
  end
end
