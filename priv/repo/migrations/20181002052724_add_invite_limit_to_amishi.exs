defmodule Cotoami.Repo.Migrations.AddInviteLimitToAmishi do
  use Ecto.Migration

  def change do
    alter table(:amishis) do
      add :invite_limit, :integer, null: true, default: 0
    end
  end
end
