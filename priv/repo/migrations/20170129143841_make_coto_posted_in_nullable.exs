defmodule Cotoami.Repo.Migrations.MakeCotoPostedInNullable do
  use Ecto.Migration

  def change do
    alter table(:cotos) do
      modify :posted_in_id, :integer, null: true
    end
  end
end
