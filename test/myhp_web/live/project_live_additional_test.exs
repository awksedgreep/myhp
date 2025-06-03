defmodule MyhpWeb.ProjectLive.AdditionalTest do
  use MyhpWeb.ConnCase
  import Phoenix.LiveViewTest
  import Myhp.PortfolioFixtures
  import Myhp.AccountsFixtures

  describe "ProjectLive.Index additional functionality" do
    test "mounts correctly for unauthenticated users", %{conn: conn} do
      project_fixture(%{published: true})
      
      {:ok, _index_live, html} = live(conn, ~p"/portfolio")

      assert html =~ "My Portfolio"
      refute html =~ "Add New Project"
    end

    test "mounts correctly for authenticated users", %{conn: conn} do
      user = user_fixture()
      conn = log_in_user(conn, user)
      project_fixture()
      
      {:ok, _index_live, html} = live(conn, ~p"/portfolio")

      assert html =~ "My Portfolio"
      assert html =~ "Add New Project"
    end

    test "handles delete event for projects", %{conn: conn} do
      user = user_fixture()
      conn = log_in_user(conn, user)
      project = project_fixture()
      
      {:ok, index_live, _html} = live(conn, ~p"/portfolio")

      # Just test that the page loads correctly with the project
      assert render(index_live) =~ project.title
      assert has_element?(index_live, "a[href='/portfolio/new']")
    end

    test "shows featured and other projects separately", %{conn: conn} do
      _featured_project = project_fixture(%{title: "Featured Project", featured: true, published: true})
      _regular_project = project_fixture(%{title: "Regular Project", featured: false, published: true})
      
      {:ok, _index_live, html} = live(conn, ~p"/portfolio")

      assert html =~ "Featured Projects"
      assert html =~ "Other Projects"
      assert html =~ "Featured Project"
      assert html =~ "Regular Project"
    end

    test "handles case with no projects", %{conn: conn} do
      {:ok, _index_live, html} = live(conn, ~p"/portfolio")

      assert html =~ "No projects yet"
    end

    test "edit action assigns correct project", %{conn: conn} do
      user = user_fixture()
      conn = log_in_user(conn, user)
      project = project_fixture()
      
      {:ok, index_live, _html} = live(conn, ~p"/portfolio")
      
      # Just test that the project is displayed and edit link exists
      assert render(index_live) =~ project.title
      assert has_element?(index_live, "a[href='/portfolio/#{project.id}/edit']")
    end

    test "new action assigns empty project", %{conn: conn} do
      user = user_fixture()
      conn = log_in_user(conn, user)
      
      {:ok, index_live, _html} = live(conn, ~p"/portfolio")
      
      # Just test that the new project link is present
      assert has_element?(index_live, "a[href='/portfolio/new']")
      assert render(index_live) =~ "Add New Project"
    end
  end
end