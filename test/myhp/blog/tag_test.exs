defmodule Myhp.Blog.TagTest do
  use Myhp.DataCase
  alias Myhp.Blog.Tag

  describe "tags" do
    @valid_attrs %{name: "elixir"}
    @invalid_attrs %{name: nil}

    test "changeset with valid attributes" do
      changeset = Tag.changeset(%Tag{}, @valid_attrs)
      assert changeset.valid?
    end

    test "changeset with invalid attributes" do
      changeset = Tag.changeset(%Tag{}, @invalid_attrs)
      refute changeset.valid?
      assert "can't be blank" in errors_on(changeset).name
    end

    test "changeset generates slug from name" do
      changeset = Tag.changeset(%Tag{}, %{name: "Phoenix LiveView"})
      assert changeset.changes.slug == "phoenix-liveview"
    end

    test "changeset validates slug uniqueness" do
      %Tag{}
      |> Tag.changeset(%{name: "elixir", slug: "elixir"})
      |> Repo.insert!()

      changeset = Tag.changeset(%Tag{}, %{name: "Elixir", slug: "elixir"})
      
      assert {:error, changeset} = Repo.insert(changeset)
      assert "has already been taken" in errors_on(changeset).slug
    end

    test "changeset validates name length" do
      changeset = Tag.changeset(%Tag{}, %{name: "a"})
      assert "should be at least 2 character(s)" in errors_on(changeset).name

      long_name = String.duplicate("a", 51)
      changeset = Tag.changeset(%Tag{}, %{name: long_name})
      assert "should be at most 50 character(s)" in errors_on(changeset).name
    end

    test "changeset normalizes name to lowercase" do
      changeset = Tag.changeset(%Tag{}, %{name: "ELIXIR"})
      assert changeset.changes.name == "elixir"
    end

    test "changeset handles special characters in name for slug" do
      changeset = Tag.changeset(%Tag{}, %{name: "C++"})
      assert changeset.changes.slug == "c"
    end

    test "changeset trims whitespace from name" do
      changeset = Tag.changeset(%Tag{}, %{name: "  elixir  "})
      assert changeset.changes.name == "elixir"
    end
  end
end