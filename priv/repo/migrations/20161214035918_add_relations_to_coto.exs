defmodule Cotoami.Repo.Migrations.AddRelationsToCoto do
  use Ecto.Migration

  def change do
    alter table(:cotos) do
      add :posted_in_id, references(:cotonomas, on_delete: :delete_all, type: :uuid), null: true
      add :as_cotonoma, :boolean, null: false, default: false
    end

    create index(:cotos, [:posted_in_id])
  end
end
