defmodule Myhp.Repo.Migrations.CreateContactMessages do
  use Ecto.Migration

  def change do
    create table(:contact_messages) do
      add :name, :string
      add :email, :string
      add :subject, :string
      add :message, :text
      add :read, :boolean, default: false, null: false

      timestamps(type: :utc_datetime)
    end
  end
end
