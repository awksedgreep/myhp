defmodule MyhpWeb.ApiControllerTest do
  use MyhpWeb.ConnCase

  describe "GET /api/blog" do
    test "returns published posts with pagination", %{conn: conn} do
      user = Myhp.AccountsFixtures.user_fixture()
      post1 = Myhp.BlogFixtures.post_fixture(%{user_id: user.id, published: true})
      post2 = Myhp.BlogFixtures.post_fixture(%{user_id: user.id, published: true})
      _draft = Myhp.BlogFixtures.post_fixture(%{user_id: user.id, published: false})

      conn = get(conn, ~p"/api/blog")
      response = json_response(conn, 200)

      assert length(response["data"]) == 2
      assert response["pagination"]["total_pages"] == 1
      assert response["pagination"]["current_page"] == 1
      
      post_titles = Enum.map(response["data"], & &1["title"])
      assert post1.title in post_titles
      assert post2.title in post_titles
    end

    test "supports pagination", %{conn: conn} do
      user = Myhp.AccountsFixtures.user_fixture()
      
      for i <- 1..15 do
        Myhp.BlogFixtures.post_fixture(%{
          user_id: user.id, 
          published: true,
          title: "Post #{i}"
        })
      end

      conn = get(conn, ~p"/api/blog?page=2&per_page=5")
      response = json_response(conn, 200)

      assert length(response["data"]) == 5
      assert response["pagination"]["current_page"] == 2
      assert response["pagination"]["total_pages"] == 3
    end

    test "supports search", %{conn: conn} do
      user = Myhp.AccountsFixtures.user_fixture()
      post1 = Myhp.BlogFixtures.post_fixture(%{
        user_id: user.id, 
        published: true,
        title: "Elixir Programming",
        content: "Learning Elixir is fun"
      })
      _post2 = Myhp.BlogFixtures.post_fixture(%{
        user_id: user.id, 
        published: true,
        title: "JavaScript Tutorial",
        content: "JavaScript basics"
      })

      conn = get(conn, ~p"/api/blog?search=Elixir")
      response = json_response(conn, 200)

      assert length(response["data"]) == 1
      assert hd(response["data"])["title"] == post1.title
    end
  end

  describe "GET /api/users" do
    test "returns users with pagination", %{conn: conn} do
      user1 = Myhp.AccountsFixtures.user_fixture(%{email: "user1@example.com"})
      user2 = Myhp.AccountsFixtures.user_fixture(%{email: "user2@example.com"})

      conn = get(conn, ~p"/api/users")
      response = json_response(conn, 200)

      assert length(response["data"]) == 2
      assert response["pagination"]["total_pages"] == 1
      
      user_emails = Enum.map(response["data"], & &1["email"])
      assert user1.email in user_emails
      assert user2.email in user_emails
    end

    test "supports search by email", %{conn: conn} do
      user1 = Myhp.AccountsFixtures.user_fixture(%{email: "john@example.com"})
      _user2 = Myhp.AccountsFixtures.user_fixture(%{email: "jane@example.com"})

      conn = get(conn, ~p"/api/users?search=john")
      response = json_response(conn, 200)

      assert length(response["data"]) == 1
      assert hd(response["data"])["email"] == user1.email
    end

    test "supports pagination", %{conn: conn} do
      for i <- 1..12 do
        Myhp.AccountsFixtures.user_fixture(%{email: "user#{i}@example.com"})
      end

      conn = get(conn, ~p"/api/users?page=2&per_page=5")
      response = json_response(conn, 200)

      assert length(response["data"]) == 5
      assert response["pagination"]["current_page"] == 2
      assert response["pagination"]["total_pages"] == 3
    end
  end

  describe "GET /api/search" do
    test "searches across posts and projects", %{conn: conn} do
      user = Myhp.AccountsFixtures.user_fixture()
      post = Myhp.BlogFixtures.post_fixture(%{
        user_id: user.id,
        published: true,
        title: "Phoenix LiveView Tutorial",
        content: "Building real-time apps"
      })
      project = Myhp.PortfolioFixtures.project_fixture(%{
        title: "Phoenix Chat App",
        description: "Real-time chat application built with Phoenix LiveView"
      })

      conn = get(conn, ~p"/api/search?q=Phoenix")
      response = json_response(conn, 200)

      assert length(response["data"]) == 2
      
      titles = Enum.map(response["data"], & &1["title"])
      assert post.title in titles
      assert project.title in titles
    end

    test "returns empty results for no matches", %{conn: conn} do
      conn = get(conn, ~p"/api/search?q=nonexistent")
      response = json_response(conn, 200)

      assert response["data"] == []
      assert response["pagination"]["total_entries"] == 0
    end

    test "supports pagination for search results", %{conn: conn} do
      user = Myhp.AccountsFixtures.user_fixture()
      
      for i <- 1..8 do
        Myhp.BlogFixtures.post_fixture(%{
          user_id: user.id,
          published: true,
          title: "Test Post #{i}",
          content: "Test content"
        })
      end

      conn = get(conn, ~p"/api/search?q=Test&per_page=3")
      response = json_response(conn, 200)

      assert length(response["data"]) == 3
      assert response["pagination"]["total_pages"] == 3
    end
  end
end