defmodule Myhp.Uploads do
  @moduledoc """
  The Uploads context.
  """

  import Ecto.Query, warn: false
  alias Myhp.Repo

  alias Myhp.Uploads.UploadedFile

  @doc """
  Returns the list of uploaded_files.

  ## Examples

      iex> list_uploaded_files()
      [%UploadedFile{}, ...]

  """
  def list_uploaded_files do
    UploadedFile
    |> order_by([u], desc: u.inserted_at)
    |> Repo.all()
  end

  @doc """
  Returns the list of uploaded files for a specific user.
  """
  def list_uploaded_files(user_id) when is_integer(user_id) do
    UploadedFile
    |> where([u], u.user_id == ^user_id)
    |> order_by([u], desc: u.inserted_at)
    |> Repo.all()
  end

  @doc """
  Returns the list of uploaded files for a specific user.
  """
  def list_user_uploaded_files(user_id) do
    UploadedFile
    |> where([u], u.user_id == ^user_id)
    |> order_by([u], desc: u.inserted_at)
    |> Repo.all()
  end

  @doc """
  Returns the list of uploaded files by type.
  """
  def list_uploaded_files_by_type(file_type) do
    UploadedFile
    |> where([u], u.file_type == ^file_type)
    |> order_by([u], desc: u.inserted_at)
    |> Repo.all()
  end

  @doc """
  Gets a single uploaded_file.

  Raises `Ecto.NoResultsError` if the Uploaded file does not exist.

  ## Examples

      iex> get_uploaded_file!(123)
      %UploadedFile{}

      iex> get_uploaded_file!(456)
      ** (Ecto.NoResultsError)

  """
  def get_uploaded_file!(id), do: Repo.get!(UploadedFile, id)

  @doc """
  Gets a single uploaded file with user preloaded.
  """
  def get_uploaded_file_with_user!(id) do
    UploadedFile
    |> Repo.get!(id)
    |> Repo.preload([:user])
  end

  @doc """
  Creates a uploaded_file.

  ## Examples

      iex> create_uploaded_file(%{field: value})
      {:ok, %UploadedFile{}}

      iex> create_uploaded_file(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_uploaded_file(attrs \\ %{}) do
    %UploadedFile{}
    |> UploadedFile.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a uploaded_file.

  ## Examples

      iex> update_uploaded_file(uploaded_file, %{field: new_value})
      {:ok, %UploadedFile{}}

      iex> update_uploaded_file(uploaded_file, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_uploaded_file(%UploadedFile{} = uploaded_file, attrs) do
    uploaded_file
    |> UploadedFile.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a uploaded_file.

  ## Examples

      iex> delete_uploaded_file(uploaded_file)
      {:ok, %UploadedFile{}}

      iex> delete_uploaded_file(uploaded_file)
      {:error, %Ecto.Changeset{}}

  """
  def delete_uploaded_file(%UploadedFile{} = uploaded_file) do
    # Delete the physical file
    delete_physical_file(uploaded_file.file_path)

    # Delete the database record
    Repo.delete(uploaded_file)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking uploaded_file changes.

  ## Examples

      iex> change_uploaded_file(uploaded_file)
      %Ecto.Changeset{data: %UploadedFile{}}

  """
  def change_uploaded_file(%UploadedFile{} = uploaded_file, attrs \\ %{}) do
    UploadedFile.changeset(uploaded_file, attrs)
  end

  @doc """
  Returns the count of uploaded files.

  ## Examples

      iex> count_uploaded_files()
      25

  """
  def count_uploaded_files do
    Repo.aggregate(UploadedFile, :count, :id)
  end

  @doc """
  Returns the total size of all uploaded files in bytes.
  """
  def total_uploaded_files_size do
    UploadedFile
    |> select([u], sum(u.file_size))
    |> Repo.one() || 0
  end

  @doc """
  Returns upload statistics.
  """
  def upload_stats do
    %{
      total_files: count_uploaded_files(),
      total_size: total_uploaded_files_size(),
      images: count_files_by_type("image"),
      documents: count_files_by_type("document"),
      other: count_files_by_type("other")
    }
  end

  defp count_files_by_type(file_type) do
    UploadedFile
    |> where([u], u.file_type == ^file_type)
    |> Repo.aggregate(:count, :id)
  end

  @doc """
  Handles file upload and saves to filesystem.
  """
  def handle_upload(upload_entry, user_id) do
    # Generate unique filename
    filename = generate_filename(upload_entry.client_name)

    # Create upload directory if it doesn't exist
    upload_dir = get_upload_dir()
    File.mkdir_p!(upload_dir)

    # Full file path
    file_path = Path.join(upload_dir, filename)

    # Copy uploaded file to destination
    case File.cp(upload_entry.path, file_path) do
      :ok ->
        # Get file info
        file_stat = File.stat!(file_path)
        file_type = determine_file_type(upload_entry.client_type)

        # Create database record
        attrs = %{
          original_filename: upload_entry.client_name,
          filename: filename,
          file_path: file_path,
          file_size: file_stat.size,
          content_type: upload_entry.client_type,
          file_type: file_type,
          user_id: user_id
        }

        create_uploaded_file(attrs)

      {:error, reason} ->
        {:error, "Failed to save file: #{reason}"}
    end
  end

  @doc """
  Returns the public URL for an uploaded file.
  """
  def file_url(%UploadedFile{} = uploaded_file) do
    "/uploads/#{uploaded_file.filename}"
  end

  @doc """
  Returns the upload directory path.
  """
  def get_upload_dir do
    upload_path = Application.get_env(:myhp, :upload_path, "priv/static/uploads")

    if String.starts_with?(upload_path, "/") do
      upload_path
    else
      Path.join(File.cwd!(), upload_path)
    end
  end

  defp generate_filename(original_filename) do
    extension = Path.extname(original_filename)
    base_name = Path.basename(original_filename, extension)
    timestamp = DateTime.utc_now() |> DateTime.to_unix()
    random = :crypto.strong_rand_bytes(8) |> Base.encode16(case: :lower)

    "#{timestamp}_#{random}_#{String.slice(base_name, 0, 50)}#{extension}"
  end

  defp determine_file_type(content_type) do
    case content_type do
      "image/" <> _ -> "image"
      "application/pdf" -> "document"
      "application/msword" -> "document"
      "application/vnd.openxmlformats-officedocument.wordprocessingml.document" -> "document"
      "text/" <> _ -> "document"
      _ -> "other"
    end
  end

  defp delete_physical_file(file_path) do
    if File.exists?(file_path) do
      File.rm(file_path)
    end
  end

  @doc """
  Returns the total storage usage for a user in bytes.
  """
  def get_user_storage_usage(user_id) do
    UploadedFile
    |> where([u], u.user_id == ^user_id)
    |> select([u], sum(u.file_size))
    |> Repo.one() || 0
  end

  @doc """
  Returns whether a user has exceeded their storage quota.
  """
  def user_exceeds_quota?(user_id, additional_size \\ 0, custom_quota \\ nil) do
    current_usage = get_user_storage_usage(user_id)
    quota = custom_quota || get_user_quota()
    (current_usage + additional_size) > quota
  end

  defp get_user_quota do
    # 1GB default quota
    Application.get_env(:myhp, :user_storage_quota, 1_073_741_824)
  end
end
