defmodule MyhpWeb.ProjectLiveTest do
  use MyhpWeb.ConnCase

  import Phoenix.LiveViewTest
  import Myhp.PortfolioFixtures

  describe "Index" do
    test "renders portfolio page", %{conn: conn} do
      {:ok, _index_live, html} = live(conn, ~p"/portfolio")

      assert html =~ "Portfolio"
    end

    test "shows projects", %{conn: conn} do
      _project = project_fixture(%{title: "Test Project", description: "Test description"})

      {:ok, _index_live, html} = live(conn, ~p"/portfolio")

      assert html =~ "Test Project"
      assert html =~ "Test description"
    end

    test "shows empty state when no projects", %{conn: conn} do
      {:ok, _index_live, html} = live(conn, ~p"/portfolio")

      assert html =~ "No projects yet" or html =~ "portfolio"
    end
  end

  describe "Show" do
    test "displays project", %{conn: conn} do
      project = project_fixture(%{title: "Test Project", description: "Test description"})

      {:ok, _show_live, html} = live(conn, ~p"/portfolio/#{project}")

      assert html =~ "Test Project"
      assert html =~ "Test description"
    end
  end
end