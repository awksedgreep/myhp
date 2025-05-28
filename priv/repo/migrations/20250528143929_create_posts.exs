defmodule Myhp.Repo.Migrations.CreatePosts do
  use Ecto.Migration

  def change do
    create table(:posts) do
      add :title, :string
      add :content, :text
      add :slug, :string
      add :published, :boolean, default: false, null: false
      add :published_at, :naive_datetime

      timestamps(type: :utc_datetime)
    end

    create unique_index(:posts, [:slug])
  end
end
