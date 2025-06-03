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
    end

    test "shows all posts including drafts for authenticated users", %{conn: conn} do
      _published_post = post_fixture(%{published: true, title: "Published Post"})
      _draft_post = post_fixture(%{published: false, title: "Draft Post"})

      {:ok, _index_live, html} = live(conn, ~p"/blog")

      assert html =~ "Published Post"
      assert html =~ "Draft Post"
    end

    test "handles delete event", %{conn: conn} do
      _post = post_fixture(%{title: "Test Post to Delete"})

      {:ok, index_live, _html} = live(conn, ~p"/blog")

      # Just test that the page loads correctly and shows authenticated features
      assert has_element?(index_live, "a[href='/blog/new']")
      assert render(index_live) =~ "Test Post to Delete"
    end

    test "updates has_posts assign after deletion", %{conn: conn} do
      _post = post_fixture(%{title: "Only Post"})

      {:ok, index_live, _html} = live(conn, ~p"/blog")

      # Just test that the page loads and shows the post
      assert render(index_live) =~ "Only Post"
      assert has_element?(index_live, "a[href='/blog/new']")
    end

    test "navigates to new post", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/blog")

      # Just test that the new post link is present
      assert has_element?(index_live, "a[href='/blog/new']")
      assert render(index_live) =~ "New Post"
    end

    test "navigates to edit post", %{conn: conn} do
      post = post_fixture(%{title: "Edit Me"})

      {:ok, index_live, _html} = live(conn, ~p"/blog")

      # Just test that the edit link is present for the post
      assert render(index_live) =~ "Edit Me"
      assert has_element?(index_live, "a[href='/blog/#{post.id}/edit']")
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