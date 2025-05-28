defmodule Myhp.UploadsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Myhp.Uploads` context.
  """

  @doc """
  Generate a uploaded_file.
  """
  def uploaded_file_fixture(attrs \\ %{}) do
    user = if attrs[:user_id], do: nil, else: Myhp.AccountsFixtures.user_fixture()
    
    {:ok, uploaded_file} =
      attrs
      |> Enum.into(%{
        original_filename: "test.jpg",
        filename: "test.jpg",
        content_type: "image/jpeg",
        file_size: 1024,
        file_path: "/uploads/test_#{System.unique_integer([:positive])}.jpg",
        file_type: "image",
        user_id: user && user.id || attrs[:user_id]
      })
      |> Myhp.Uploads.create_uploaded_file()

    uploaded_file
  end
end