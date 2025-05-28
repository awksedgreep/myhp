defmodule Myhp.UploadsTest do
  use Myhp.DataCase
  alias Myhp.Uploads

  describe "uploaded_files" do
    alias Myhp.Uploads.UploadedFile

    import Myhp.UploadsFixtures

    @invalid_attrs %{filename: nil, content_type: nil, file_size: nil}

    test "list_uploaded_files/0 returns all uploaded_files" do
      uploaded_file = uploaded_file_fixture()
      assert Uploads.list_uploaded_files() == [uploaded_file]
    end

    test "get_uploaded_file!/1 returns the uploaded_file with given id" do
      uploaded_file = uploaded_file_fixture()
      assert Uploads.get_uploaded_file!(uploaded_file.id) == uploaded_file
    end

    test "create_uploaded_file/1 with valid data creates a uploaded_file" do
      user = Myhp.AccountsFixtures.user_fixture()
      valid_attrs = %{
        original_filename: "test.jpg",
        filename: "test.jpg",
        content_type: "image/jpeg", 
        file_size: 1024,
        file_path: "/uploads/test.jpg",
        file_type: "image",
        user_id: user.id
      }

      assert {:ok, %UploadedFile{} = uploaded_file} = Uploads.create_uploaded_file(valid_attrs)
      assert uploaded_file.filename == "test.jpg"
      assert uploaded_file.content_type == "image/jpeg"
      assert uploaded_file.file_size == 1024
      assert uploaded_file.file_path == "/uploads/test.jpg"
      assert uploaded_file.user_id == user.id
    end

    test "create_uploaded_file/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Uploads.create_uploaded_file(@invalid_attrs)
    end

    test "update_uploaded_file/2 with valid data updates the uploaded_file" do
      uploaded_file = uploaded_file_fixture()
      update_attrs = %{filename: "updated.jpg", content_type: "image/png", file_size: 2048}

      assert {:ok, %UploadedFile{} = uploaded_file} = Uploads.update_uploaded_file(uploaded_file, update_attrs)
      assert uploaded_file.filename == "updated.jpg"
      assert uploaded_file.content_type == "image/png"
      assert uploaded_file.file_size == 2048
    end

    test "update_uploaded_file/2 with invalid data returns error changeset" do
      uploaded_file = uploaded_file_fixture()
      assert {:error, %Ecto.Changeset{}} = Uploads.update_uploaded_file(uploaded_file, @invalid_attrs)
      assert uploaded_file == Uploads.get_uploaded_file!(uploaded_file.id)
    end

    test "delete_uploaded_file/1 deletes the uploaded_file" do
      uploaded_file = uploaded_file_fixture()
      assert {:ok, %UploadedFile{}} = Uploads.delete_uploaded_file(uploaded_file)
      assert_raise Ecto.NoResultsError, fn -> Uploads.get_uploaded_file!(uploaded_file.id) end
    end

    test "change_uploaded_file/1 returns a uploaded_file changeset" do
      uploaded_file = uploaded_file_fixture()
      assert %Ecto.Changeset{} = Uploads.change_uploaded_file(uploaded_file)
    end

    test "list_uploaded_files/1 filters by user" do
      user1 = Myhp.AccountsFixtures.user_fixture()
      user2 = Myhp.AccountsFixtures.user_fixture()
      
      file1 = uploaded_file_fixture(%{user_id: user1.id})
      _file2 = uploaded_file_fixture(%{user_id: user2.id})
      
      assert Uploads.list_uploaded_files(user1.id) == [file1]
    end

    test "validates file size limits" do
      user = Myhp.AccountsFixtures.user_fixture()
      attrs = %{
        filename: "large.jpg",
        content_type: "image/jpeg",
        file_size: 100_000_000, # 100MB
        file_path: "/uploads/large.jpg",
        user_id: user.id
      }

      assert {:error, %Ecto.Changeset{} = changeset} = Uploads.create_uploaded_file(attrs)
      assert "must be less than 10MB" in errors_on(changeset).file_size
    end

    test "validates allowed content types" do
      user = Myhp.AccountsFixtures.user_fixture()
      attrs = %{
        filename: "script.exe",
        content_type: "application/x-executable",
        file_size: 1024,
        file_path: "/uploads/script.exe", 
        user_id: user.id
      }

      assert {:error, %Ecto.Changeset{} = changeset} = Uploads.create_uploaded_file(attrs)
      assert "is not an allowed file type" in errors_on(changeset).content_type
    end

    test "generates unique file paths for duplicate filenames" do
      user = Myhp.AccountsFixtures.user_fixture()
      
      attrs1 = %{
        original_filename: "test.jpg",
        filename: "test.jpg",
        content_type: "image/jpeg",
        file_size: 1024,
        file_path: "/uploads/test1.jpg",
        file_type: "image",
        user_id: user.id
      }
      
      attrs2 = %{
        original_filename: "test.jpg",
        filename: "test.jpg", 
        content_type: "image/jpeg",
        file_size: 2048,
        file_path: "/uploads/test2.jpg",
        file_type: "image",
        user_id: user.id
      }

      assert {:ok, file1} = Uploads.create_uploaded_file(attrs1)
      assert {:ok, file2} = Uploads.create_uploaded_file(attrs2)
      
      assert file1.file_path != file2.file_path
      assert String.contains?(file2.file_path, "test")
      assert String.contains?(file2.file_path, ".jpg")
    end

    test "calculates storage usage for user" do
      user = Myhp.AccountsFixtures.user_fixture()
      
      uploaded_file_fixture(%{user_id: user.id, file_size: 1024})
      uploaded_file_fixture(%{user_id: user.id, file_size: 2048})
      
      assert Uploads.get_user_storage_usage(user.id) == 3072
    end

    test "enforces storage quota per user" do
      user = Myhp.AccountsFixtures.user_fixture()
      
      # Create files up to the test quota (100MB for tests)
      # Create 20 files of 5MB each = 100MB total  
      for _i <- 1..20 do
        uploaded_file_fixture(%{user_id: user.id, file_size: 5_000_000}) # 5MB each
      end
      
      # Try to upload one more that would exceed quota
      attrs = %{
        original_filename: "overflow.jpg",
        filename: "overflow.jpg",
        content_type: "image/jpeg",
        file_size: 5_000_000, # 5MB (would exceed 100MB test quota)
        file_path: "/uploads/overflow.jpg",
        file_type: "image",
        user_id: user.id
      }
      
      assert {:error, %Ecto.Changeset{} = changeset} = Uploads.create_uploaded_file(attrs)
      assert "would exceed storage quota" in errors_on(changeset).file_size
    end
  end
end