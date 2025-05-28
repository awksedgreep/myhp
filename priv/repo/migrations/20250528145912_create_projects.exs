defmodule Myhp.Repo.Migrations.CreateProjects do
  use Ecto.Migration

  def change do
    create table(:projects) do
      add :title, :string
      add :description, :text
      add :technologies, :text
      add :github_url, :string
      add :live_url, :string
      add :image_url, :string
      add :featured, :boolean, default: false, null: false
      add :published, :boolean, default: false, null: false

      timestamps(type: :utc_datetime)
    end
  end
end
