defmodule Cotoami.Repo.Migrations.CreateCotonoma do
  use Ecto.Migration

  def change do
    create table(:cotonomas) do
      add :key, :string, null: false
      add :name, :string, null: false
      add :coto_id, references(:cotos, on_delete: :delete_all), null: false
      add :owner_id, references(:amishis, on_delete: :delete_all), null: false

      timestamps()
    end

    create unique_index(:cotonomas, [:key])
    create unique_index(:cotonomas, [:name, :owner_id], name: :cotonomas_name_owner_id_index)
    create index(:cotonomas, [:coto_id])
    create index(:cotonomas, [:owner_id])
  end
end
