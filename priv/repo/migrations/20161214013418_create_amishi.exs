defmodule Cotoami.Repo.Migrations.CreateAmishi do
  use Ecto.Migration

  def change do
    create table(:amishis) do
      add :email, :string, null: false

      timestamps()
    end

    create unique_index(:amishis, [:email])
  end
end
