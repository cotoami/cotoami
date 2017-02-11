defmodule Cotoami.Repo.Migrations.CreateMemberInheritance do
  use Ecto.Migration

  def change do
    create table(:member_inheritances) do
      add :from_id, references(:cotonomas, on_delete: :delete_all), null: false
      add :to_id, references(:cotonomas, on_delete: :delete_all), null: false

      timestamps()
    end
    
    create index(:member_inheritances, [:from_id])
    create index(:member_inheritances, [:to_id])
    create unique_index(:member_inheritances, [:to_id, :from_id], name: :member_inheritances_to_id_from_id_index)
  end
end
