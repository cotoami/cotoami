defmodule Cotoami.Repo.Migrations.AddPinnedFlagToCotonoma do
  use Ecto.Migration

  def change do
    alter table(:cotonomas) do
      add :pinned, :boolean, null: false, default: false
    end
  end
end
