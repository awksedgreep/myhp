defmodule MyhpWeb.RssControllerTest do
  use MyhpWeb.ConnCase

  describe "GET /rss" do
    test "returns RSS feed with published posts", %{conn: conn} do
      # Create some published posts
      _post1 = Myhp.BlogFixtures.post_fixture(%{
        title: "First Post",
        content: "First post content",
        published: true
      })
      
      _post2 = Myhp.BlogFixtures.post_fixture(%{
        title: "Second Post", 
        content: "Second post content",
        published: true
      })
      
      # Create unpublished post (should not appear)
      _draft = Myhp.BlogFixtures.post_fixture(%{
        title: "Draft Post",
        content: "Draft content",
        published: false
      })

      conn = get(conn, ~p"/rss")
      
      response = response(conn, 200)
      
      # Check content type
      assert get_resp_header(conn, "content-type") == ["application/rss+xml; charset=utf-8"]
      
      # Check XML structure
      assert response =~ "<?xml"
      assert response =~ "<rss"
      assert response =~ "<channel>"
      
      # Check published posts are included
      assert response =~ "First Post"
      assert response =~ "Second Post"
      assert response =~ "First post content"
      assert response =~ "Second post content"
      
      # Check draft is not included
      refute response =~ "Draft Post"
    end

    test "returns empty feed when no published posts", %{conn: conn} do
      conn = get(conn, ~p"/rss")
      
      response = response(conn, 200)
      
      assert get_resp_header(conn, "content-type") == ["application/rss+xml; charset=utf-8"]
      assert response =~ "<?xml"
      assert response =~ "<rss"
      assert response =~ "<channel>"
    end

    test "limits feed to 20 posts", %{conn: conn} do
      # Create 25 published posts
      for i <- 1..25 do
        Myhp.BlogFixtures.post_fixture(%{
          title: "Post #{i}",
          content: "Content #{i}",
          published: true
        })
      end

      conn = get(conn, ~p"/rss")
      response = response(conn, 200)
      
      # Count number of <item> elements (should be 20)
      item_count = response
                   |> String.split("<item>")
                   |> length()
                   |> Kernel.-(1) # Subtract 1 because split creates extra element
      
      assert item_count == 20
    end
  end

  describe "GET /feed" do
    test "alternate feed URL works", %{conn: conn} do
      _post = Myhp.BlogFixtures.post_fixture(%{
        title: "Test Post",
        content: "Test content", 
        published: true
      })

      conn = get(conn, ~p"/feed")
      response = response(conn, 200)
      
      assert get_resp_header(conn, "content-type") == ["application/rss+xml; charset=utf-8"]
      assert response =~ "Test Post"
    end
  end
end