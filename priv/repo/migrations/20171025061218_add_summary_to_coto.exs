defmodule Cotoami.Repo.Migrations.AddSummaryToCoto do
  use Ecto.Migration

  def change do
    alter table(:cotos) do
      add :summary, :string, null: true
    end
  end
end
