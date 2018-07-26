defmodule Cotoami.Repo.Migrations.AddSharedFlagToCotonoma do
  use Ecto.Migration

  def change do
    alter table(:cotonomas) do
      add :shared, :boolean, null: false, default: false
    end
  end
end
