defmodule Myhp.Repo.Migrations.CreateUploadedFiles do
  use Ecto.Migration

  def change do
    create table(:uploaded_files) do
      add :original_filename, :string, null: false
      add :filename, :string, null: false
      add :file_path, :string, null: false
      add :file_size, :integer, null: false
      add :content_type, :string, null: false
      add :file_type, :string, null: false
      add :description, :text
      add :alt_text, :string
      add :user_id, references(:users, on_delete: :delete_all), null: false

      timestamps(type: :utc_datetime)
    end

    create index(:uploaded_files, [:user_id])
    create index(:uploaded_files, [:file_type])
    create index(:uploaded_files, [:inserted_at])
  end
end
