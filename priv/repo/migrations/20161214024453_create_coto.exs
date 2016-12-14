defmodule Cotoami.Repo.Migrations.CreateCoto do
  use Ecto.Migration

  def change do
    create table(:cotos) do
      add :content, :text, null: false
      add :amishi_id, references(:amishis, on_delete: :nothing)

      timestamps()
    end
    
    create index(:cotos, [:amishi_id])
  end
end
