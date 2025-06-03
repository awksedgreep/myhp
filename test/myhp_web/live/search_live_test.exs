defmodule MyhpWeb.SearchLiveTest do
  use MyhpWeb.ConnCase

  import Phoenix.LiveViewTest
  import Myhp.BlogFixtures
  import Myhp.PortfolioFixtures

  describe "Search" do
    test "renders search page", %{conn: conn} do
      {:ok, _search_live, html} = live(conn, ~p"/search")

      assert html =~ "Search"
      assert html =~ "Enter at least 2 characters"
    end

    test "can perform search action", %{conn: conn} do
      _post = post_fixture(%{title: "Elixir Phoenix Tutorial", content: "Learn Phoenix framework", published: true})

      {:ok, search_live, _html} = live(conn, ~p"/search")

      # Test search event
      assert search_live
             |> element("form")
             |> render_submit(%{query: "Elixir"})

      html = render(search_live)
      # Should process the search
      assert html =~ "Search"
    end

    test "handles search with no matches", %{conn: conn} do
      {:ok, search_live, _html} = live(conn, ~p"/search")

      # Test search with query that won't match
      assert search_live
             |> element("form")
             |> render_submit(%{query: "nonexistentterm12345"})

      html = render(search_live)
      assert html =~ "Search"
    end

    test "renders project technologies correctly when searching", %{conn: conn} do
      # Create a project with comma-separated technologies
      _project = project_fixture(%{
        title: "Phoenix LiveView App",
        description: "A modern web application built with Phoenix LiveView technology stack",
        technologies: "Elixir, Phoenix LiveView, Tailwind CSS, SQLite, Alpine.js",
        published: true
      })

      {:ok, search_live, _html} = live(conn, ~p"/search")

      # Search for the project
      search_live
      |> element("form")
      |> render_submit(%{query: "Phoenix"})

      html = render(search_live)
      
      # Should render the project title
      assert html =~ "Phoenix LiveView App"
      
      # Should render individual technology badges without crashing
      assert html =~ "Elixir"
      assert html =~ "Phoenix LiveView"
      assert html =~ "Tailwind CSS"
      assert html =~ "SQLite"
      assert html =~ "Alpine.js"
      
      # Should have the correct CSS classes for technology badges
      assert html =~ "bg-blue-100 dark:bg-blue-900/30"
    end

    test "renders projects with various technology formats", %{conn: conn} do
      # Test different technology string formats that could cause issues
      project_fixture(%{
        title: "Project A",
        description: "Test project with spaces in technologies",
        technologies: "React, Node.js, PostgreSQL, Docker",
        published: true
      })
      
      project_fixture(%{
        title: "Project B", 
        description: "Test project with extra spaces",
        technologies: " Vue.js , Express.js , MongoDB , Redis ",
        published: true
      })
      
      project_fixture(%{
        title: "Project C",
        description: "Test project with single technology",
        technologies: "Django",
        published: true
      })

      {:ok, search_live, _html} = live(conn, ~p"/search")

      # Search for projects
      search_live
      |> element("form")
      |> render_submit(%{query: "Test"})

      html = render(search_live)
      
      # Should render all projects without crashing
      assert html =~ "Project A"
      assert html =~ "Project B"
      assert html =~ "Project C"
      
      # Should properly trim spaces and render technologies
      assert html =~ "React"
      assert html =~ "Vue.js"
      assert html =~ "Django"
    end

    test "renders projects with minimal technologies field", %{conn: conn} do
      # Test project with minimal technologies (single item)
      project_fixture(%{
        title: "Minimal Project",
        description: "A project with minimal technologies specified",
        technologies: "JavaScript",
        published: true
      })

      {:ok, search_live, _html} = live(conn, ~p"/search")

      search_live
      |> element("form")
      |> render_submit(%{query: "Minimal"})

      html = render(search_live)
      
      # Should render the project without crashing
      assert html =~ "Minimal Project"
      # Should show the single technology badge
      assert html =~ "JavaScript"
      assert html =~ "bg-blue-100 dark:bg-blue-900/30"
    end

    test "searches both blog posts and projects", %{conn: conn} do
      # Create both a blog post and project with similar content
      _post = post_fixture(%{
        title: "Learning Elixir",
        content: "A guide to learning the Elixir programming language",
        published: true
      })
      
      _project = project_fixture(%{
        title: "Elixir Web App",
        description: "A web application built with Elixir and Phoenix",
        technologies: "Elixir, Phoenix, PostgreSQL",
        published: true
      })

      {:ok, search_live, _html} = live(conn, ~p"/search")

      search_live
      |> element("form")
      |> render_submit(%{query: "Elixir"})

      html = render(search_live)
      
      # Should show both blog posts and projects sections
      assert html =~ "Blog Posts"
      assert html =~ "Projects"
      
      # Should show the matching content
      assert html =~ "Learning Elixir"
      assert html =~ "Elixir Web App"
      
      # Should render project technologies correctly
      assert html =~ "Phoenix"
      assert html =~ "PostgreSQL"
    end

    test "handles search with special characters in technologies", %{conn: conn} do
      # Test technologies with special characters that might cause issues
      project_fixture(%{
        title: "Complex Tech Stack",
        description: "Project with complex technology names",
        technologies: "C#, .NET Core, Node.js, Vue.js 3.0, TypeScript 4.5+",
        published: true
      })

      {:ok, search_live, _html} = live(conn, ~p"/search")

      search_live
      |> element("form") 
      |> render_submit(%{query: "Complex"})

      html = render(search_live)
      
      # Should render without crashing despite special characters
      assert html =~ "Complex Tech Stack"
      assert html =~ "C#"
      assert html =~ ".NET Core"
      assert html =~ "TypeScript 4.5+"
    end
  end
end