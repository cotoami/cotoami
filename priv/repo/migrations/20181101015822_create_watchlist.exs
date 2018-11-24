defmodule Cotoami.Repo.Migrations.CreateWatchlist do
  use Ecto.Migration

  def change do
    create table(:watchlist, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :amishi_id, references(:amishis, on_delete: :delete_all, type: :uuid), null: false
      add :cotonoma_id, references(:cotonomas, on_delete: :delete_all, type: :uuid), null: false
      add :last_post_timestamp, :utc_datetime, null: true

      timestamps(type: :utc_datetime)
    end

    create index(:watchlist, [:amishi_id])
    create index(:watchlist, [:cotonoma_id])
    create unique_index(:watchlist, [:cotonoma_id, :amishi_id], name: :watchlist_cotonoma_id_amishi_id_index)

    alter table(:cotonomas) do
      add :last_post_timestamp, :utc_datetime, null: true
    end
  end
end
