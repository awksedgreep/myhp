defmodule MyhpWeb.PostLiveTest do
  use MyhpWeb.ConnCase

  import Phoenix.LiveViewTest
  import Myhp.BlogFixtures

  describe "Index" do
    test "renders blog posts page", %{conn: conn} do
      {:ok, _index_live, html} = live(conn, ~p"/blog")

      assert html =~ "Blog Posts"
      assert html =~ "RSS Feed"
    end

    test "shows published posts to public users", %{conn: conn} do
      _published_post = post_fixture(%{published: true, title: "Published Post"})
      _draft_post = post_fixture(%{published: false, title: "Draft Post"})

      {:ok, _index_live, html} = live(conn, ~p"/blog")

      assert html =~ "Published Post"
      refute html =~ "Draft Post"
    end

    test "shows empty state when no posts", %{conn: conn} do
      {:ok, _index_live, html} = live(conn, ~p"/blog")

      assert html =~ "No blog posts"
    end
  end

  describe "Index with auth" do
    setup [:register_and_log_in_user]

    test "renders for authenticated users", %{conn: conn} do
      {:ok, _index_live, html} = live(conn, ~p"/blog")

      assert html =~ "Blog Posts"
      # Note: New Post button may require admin privileges
    end
  end

  describe "Show" do
    test "displays post", %{conn: conn} do
      post = post_fixture(%{published: true, title: "Test Post", content: "Test content"})

      {:ok, _show_live, html} = live(conn, ~p"/blog/#{post}")

      assert html =~ "Test Post"
      assert html =~ "Test content"
    end
  end
end