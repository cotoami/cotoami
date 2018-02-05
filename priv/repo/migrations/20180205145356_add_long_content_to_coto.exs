defmodule Cotoami.Repo.Migrations.AddLongContentToCoto do
  use Ecto.Migration

  def change do
    alter table(:cotos) do
      add :long_content, :text, null: true
    end
  end
end
