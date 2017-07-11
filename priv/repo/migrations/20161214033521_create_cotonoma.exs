defmodule Cotoami.Repo.Migrations.CreateCotonoma do
  use Ecto.Migration

  def change do
    create table(:cotonomas, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :key, :string, null: false
      add :name, :string, null: false
      add :coto_id, references(:cotos, on_delete: :delete_all, type: :uuid), null: false
      add :owner_id, references(:amishis, on_delete: :delete_all, type: :uuid), null: false

      timestamps()
    end

    create unique_index(:cotonomas, [:key])
    create unique_index(:cotonomas, [:name, :owner_id], name: :cotonomas_name_owner_id_index)
    create index(:cotonomas, [:coto_id])
    create index(:cotonomas, [:owner_id])
  end
end
