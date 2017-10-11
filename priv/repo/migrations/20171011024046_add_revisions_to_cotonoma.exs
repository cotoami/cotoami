defmodule Cotoami.Repo.Migrations.AddRevisionsToCotonoma do
  use Ecto.Migration

  def change do
    alter table(:cotonomas) do
      add :timeline_revision, :integer, null: false, default: 0
      add :graph_revision, :integer, null: false, default: 0
    end
  end
end
