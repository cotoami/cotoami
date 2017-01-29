defmodule Cotoami.Repo.Migrations.MakeCotonomaNameNotNullable do
  use Ecto.Migration

  def change do
    alter table(:cotonomas) do
      modify :name, :string, null: false
    end
  end
end
