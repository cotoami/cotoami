defmodule Cotoami.Repo.Migrations.CreateCoto do
  use Ecto.Migration

  def change do
    create table(:cotos, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :content, :text, null: false
      add :amishi_id, references(:amishis, on_delete: :delete_all, type: :uuid), null: false

      timestamps(type: :utc_datetime)
    end

    create index(:cotos, [:amishi_id])
  end
end
