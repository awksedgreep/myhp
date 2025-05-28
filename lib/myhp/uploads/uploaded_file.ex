defmodule Myhp.Uploads.UploadedFile do
  use Ecto.Schema
  import Ecto.Changeset

  alias Myhp.Accounts.User

  schema "uploaded_files" do
    field :original_filename, :string
    field :filename, :string
    field :file_path, :string
    field :file_size, :integer
    field :content_type, :string
    field :file_type, :string
    field :description, :string
    field :alt_text, :string

    belongs_to :user, User

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(uploaded_file, attrs) do
    uploaded_file
    |> cast(attrs, [
      :original_filename,
      :filename,
      :file_path,
      :file_size,
      :content_type,
      :file_type,
      :description,
      :alt_text,
      :user_id
    ])
    |> validate_required([
      :original_filename,
      :filename,
      :file_path,
      :file_size,
      :content_type,
      :file_type,
      :user_id
    ])
    |> validate_length(:original_filename, max: 255)
    |> validate_length(:filename, max: 255)
    |> validate_length(:description, max: 1000)
    |> validate_length(:alt_text, max: 255)
    |> validate_number(:file_size, greater_than: 0)
    |> validate_file_size()
    |> validate_content_type()
    |> validate_storage_quota()
    |> validate_inclusion(:file_type, ["image", "document", "other"])
    |> foreign_key_constraint(:user_id)
  end

  defp validate_file_size(changeset) do
    # 10MB max file size
    max_size = 10 * 1024 * 1024
    validate_number(changeset, :file_size, less_than: max_size, message: "must be less than 10MB")
  end

  defp validate_content_type(changeset) do
    allowed_types = [
      # Images
      "image/jpeg", "image/png", "image/gif", "image/webp",
      # Documents
      "application/pdf", "application/msword",
      "application/vnd.openxmlformats-officedocument.wordprocessingml.document",
      "text/plain", "text/csv"
    ]

    content_type = get_field(changeset, :content_type)
    
    if content_type && content_type not in allowed_types do
      add_error(changeset, :content_type, "is not an allowed file type")
    else
      changeset
    end
  end

  defp validate_storage_quota(changeset) do
    user_id = get_field(changeset, :user_id)
    file_size = get_field(changeset, :file_size)

    if user_id && file_size do
      # Use a smaller quota for testing
      test_quota = if Mix.env() == :test, do: 100_000_000, else: nil # 100MB for tests
      
      if Myhp.Uploads.user_exceeds_quota?(user_id, file_size, test_quota) do
        add_error(changeset, :file_size, "would exceed storage quota")
      else
        changeset
      end
    else
      changeset
    end
  end
end
