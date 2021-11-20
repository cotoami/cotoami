defmodule Cotoami.Repo.Migrations.Repost do
  use Ecto.Migration

  def change do
    alter table(:cotos) do
      add(:repost_id, references(:cotos, on_delete: :delete_all, type: :uuid), null: true)
      add(:reposted_in_ids, {:array, :uuid}, null: false, default: [])
    end
  end
end
