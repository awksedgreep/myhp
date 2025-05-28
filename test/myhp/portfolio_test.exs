defmodule Myhp.PortfolioTest do
  use Myhp.DataCase

  alias Myhp.Portfolio

  describe "projects" do
    alias Myhp.Portfolio.Project

    import Myhp.PortfolioFixtures

    @invalid_attrs %{
      description: nil,
      title: nil,
      technologies: nil,
      github_url: nil,
      live_url: nil,
      image_url: nil,
      featured: nil,
      published: nil
    }

    test "list_projects/0 returns all projects" do
      project = project_fixture()
      assert Portfolio.list_projects() == [project]
    end

    test "get_project!/1 returns the project with given id" do
      project = project_fixture()
      assert Portfolio.get_project!(project.id) == project
    end

    test "create_project/1 with valid data creates a project" do
      valid_attrs = %{
        description: "This is a sample project description that meets minimum length requirement.",
        title: "Test Project",
        technologies: "Elixir, Phoenix",
        github_url: "https://github.com/test/project",
        live_url: "https://example.com/project",
        image_url: "https://example.com/image.png",
        featured: true,
        published: true
      }

      assert {:ok, %Project{} = project} = Portfolio.create_project(valid_attrs)
      assert project.description == "This is a sample project description that meets minimum length requirement."
      assert project.title == "Test Project"
      assert project.technologies == "Elixir, Phoenix"
      assert project.github_url == "https://github.com/test/project"
      assert project.live_url == "https://example.com/project"
      assert project.image_url == "https://example.com/image.png"
      assert project.featured == true
      assert project.published == true
    end

    test "create_project/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Portfolio.create_project(@invalid_attrs)
    end

    test "update_project/2 with valid data updates the project" do
      project = project_fixture()

      update_attrs = %{
        description: "This is an updated project description that also meets the minimum length requirement.",
        title: "Updated Project Title",
        technologies: "Updated technologies list",
        github_url: "https://github.com/updated/project",
        live_url: "https://updated.example.com/project",
        image_url: "https://updated.example.com/image.png",
        featured: false,
        published: false
      }

      assert {:ok, %Project{} = project} = Portfolio.update_project(project, update_attrs)
      assert project.description == "This is an updated project description that also meets the minimum length requirement."
      assert project.title == "Updated Project Title"
      assert project.technologies == "Updated technologies list"
      assert project.github_url == "https://github.com/updated/project"
      assert project.live_url == "https://updated.example.com/project"
      assert project.image_url == "https://updated.example.com/image.png"
      assert project.featured == false
      assert project.published == false
    end

    test "update_project/2 with invalid data returns error changeset" do
      project = project_fixture()
      assert {:error, %Ecto.Changeset{}} = Portfolio.update_project(project, @invalid_attrs)
      assert project == Portfolio.get_project!(project.id)
    end

    test "delete_project/1 deletes the project" do
      project = project_fixture()
      assert {:ok, %Project{}} = Portfolio.delete_project(project)
      assert_raise Ecto.NoResultsError, fn -> Portfolio.get_project!(project.id) end
    end

    test "change_project/1 returns a project changeset" do
      project = project_fixture()
      assert %Ecto.Changeset{} = Portfolio.change_project(project)
    end
  end
end
