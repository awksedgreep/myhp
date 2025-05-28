defmodule Myhp.Repo.Migrations.CreateCategories do
  use Ecto.Migration

  def change do
    create table(:categories) do
      add :name, :string, null: false
      add :slug, :string, null: false
      add :description, :text
      add :color, :string, default: "#3B82F6"

      timestamps(type: :utc_datetime)
    end

    create unique_index(:categories, [:name])
    create unique_index(:categories, [:slug])

    # Add category_id to posts
    alter table(:posts) do
      add :category_id, references(:categories, on_delete: :nilify_all)
    end

    create index(:posts, [:category_id])
  end
end
