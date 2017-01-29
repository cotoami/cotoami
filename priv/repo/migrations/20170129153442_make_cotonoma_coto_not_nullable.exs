defmodule Cotoami.Repo.Migrations.MakeCotonomaCotoNotNullable do
  use Ecto.Migration

  def change do
    alter table(:cotonomas) do
      modify :coto_id, :integer, null: false
    end
  end
end
