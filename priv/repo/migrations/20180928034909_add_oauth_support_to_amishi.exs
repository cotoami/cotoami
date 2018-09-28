defmodule Cotoami.Repo.Migrations.AddOauthSupportToAmishi do
  use Ecto.Migration

  def change do
    alter table(:amishis) do
      modify :email, :string, null: true
      add :auth_provider, :string, null: true
      add :auth_id, :string, null: true
      add :name, :string, null: true
      add :avatar_url, :string, null: true
      add :disabled, :boolean, null: false, default: false
      add :inviter_id, references(:amishis, on_delete: :nilify_all, type: :uuid), null: true
    end

    create unique_index(:amishis, [:auth_id, :auth_provider], name: :amishis_auth_id_auth_provider_index)
  end
end
