defmodule Myhp.Repo.Migrations.AddAdminAndBannedFieldsToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :admin, :boolean, default: false, null: false
      add :banned_at, :utc_datetime
    end

    create index(:users, [:admin])
    create index(:users, [:banned_at])
  end
end
