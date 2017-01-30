defmodule Cotoami.Repo.Migrations.MakeCotonomaNameUniqueForOwner do
  use Ecto.Migration

  def change do
    create unique_index(:cotonomas, [:name, :owner_id], name: :cotonomas_name_owner_id_index)
  end
end
