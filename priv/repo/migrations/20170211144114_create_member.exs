defmodule Cotoami.Repo.Migrations.CreateMember do
  use Ecto.Migration

  def change do
    create table(:members) do
      add :email, :string, null: false
      add :cotonoma_id, references(:cotonomas, on_delete: :delete_all), null: false
      add :amishi_id, references(:amishis, on_delete: :delete_all), null: true

      timestamps()
    end
    
    create index(:members, [:cotonoma_id])
    create index(:members, [:amishi_id])
    create unique_index(:members, [:email, :cotonoma_id], name: :members_email_cotonoma_id_index)
  end
end
