defmodule Myhp.Blog.CategoryTest do
  use Myhp.DataCase
  alias Myhp.Blog.Category

  describe "categories" do
    @valid_attrs %{name: "Technology", description: "Tech-related posts"}
    @invalid_attrs %{name: nil, description: nil}

    test "changeset with valid attributes" do
      changeset = Category.changeset(%Category{}, @valid_attrs)
      assert changeset.valid?
    end

    test "changeset with invalid attributes" do
      changeset = Category.changeset(%Category{}, @invalid_attrs)
      refute changeset.valid?
      assert "can't be blank" in errors_on(changeset).name
    end

    test "changeset generates slug from name" do
      changeset = Category.changeset(%Category{}, %{name: "Web Development"})
      assert changeset.changes.slug == "web-development"
    end

    test "changeset validates slug uniqueness" do
      %Category{}
      |> Category.changeset(%{name: "Tech", slug: "technology"})
      |> Repo.insert!()

      changeset = Category.changeset(%Category{}, %{name: "Technology", slug: "technology"})
      
      assert {:error, changeset} = Repo.insert(changeset)
      assert "has already been taken" in errors_on(changeset).slug
    end

    test "changeset validates name length" do
      changeset = Category.changeset(%Category{}, %{name: "A"})
      assert "should be at least 2 character(s)" in errors_on(changeset).name

      long_name = String.duplicate("a", 101)
      changeset = Category.changeset(%Category{}, %{name: long_name})
      assert "should be at most 100 character(s)" in errors_on(changeset).name
    end

    test "changeset validates description length" do
      long_description = String.duplicate("a", 501)
      changeset = Category.changeset(%Category{}, %{name: "Tech", description: long_description})
      assert "should be at most 500 character(s)" in errors_on(changeset).description
    end

    test "changeset handles special characters in name for slug" do
      changeset = Category.changeset(%Category{}, %{name: "C++ & Programming!"})
      assert changeset.changes.slug == "c-programming"
    end
  end
end