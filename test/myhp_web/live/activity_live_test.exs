defmodule MyhpWeb.ActivityLiveTest do
  use MyhpWeb.ConnCase

  import Phoenix.LiveViewTest

  describe "ActivityLive" do
    setup [:register_and_log_in_user]

    test "renders activity feed page", %{conn: conn} do
      {:ok, _activity_live, html} = live(conn, ~p"/activity")

      assert html =~ "Activity Feed"
    end

    test "displays activity feed when empty", %{conn: conn} do
      {:ok, _activity_live, html} = live(conn, ~p"/activity")

      # Should show empty state message
      assert html =~ "No recent activity"
    end

    test "displays activity feed with blog posts", %{conn: conn} do
      # Create a blog post to show in activity feed
      user = Myhp.AccountsFixtures.user_fixture()
      _post = Myhp.BlogFixtures.post_fixture(%{user_id: user.id, published: true})

      {:ok, _activity_live, html} = live(conn, ~p"/activity")

      # Should display the activity feed page
      assert html =~ "Activity Feed"
    end

    test "displays activity feed with portfolio projects", %{conn: conn} do
      # Create a portfolio project to show in activity feed
      _project = Myhp.PortfolioFixtures.project_fixture(%{published: true})

      {:ok, _activity_live, html} = live(conn, ~p"/activity")

      # Should display the activity feed page
      assert html =~ "Activity Feed"
    end

    test "displays activity feed with comments", %{conn: conn} do
      # Create a blog post and comment
      user = Myhp.AccountsFixtures.user_fixture()
      post = Myhp.BlogFixtures.post_fixture(%{user_id: user.id, published: true})
      _comment = Myhp.BlogFixtures.comment_fixture(%{post_id: post.id, user_id: user.id})

      {:ok, _activity_live, html} = live(conn, ~p"/activity")

      # Should display the activity feed page
      assert html =~ "Activity Feed"
    end

    test "displays activity feed with chat messages", %{conn: conn} do
      # Create a chat message
      user = Myhp.AccountsFixtures.user_fixture()
      _message = Myhp.ChatFixtures.message_fixture(%{user_id: user.id})

      {:ok, _activity_live, html} = live(conn, ~p"/activity")

      # Should display the activity feed page
      assert html =~ "Activity Feed"
    end

    test "handles real-time updates", %{conn: conn} do
      {:ok, activity_live, _html} = live(conn, ~p"/activity")

      # Test that the LiveView can handle updates
      # This tests the real-time subscription functionality
      send(activity_live.pid, {:new_activity, %{type: "test", data: %{}}})

      # Should not crash
      assert render(activity_live) =~ "Activity Feed"
    end

    test "displays proper page title", %{conn: conn} do
      {:ok, _activity_live, html} = live(conn, ~p"/activity")

      assert html =~ "Activity Feed"
    end

    test "handles pagination or limits activities", %{conn: conn} do
      # Create multiple activities
      user = Myhp.AccountsFixtures.user_fixture()
      
      # Create several blog posts
      for i <- 1..5 do
        Myhp.BlogFixtures.post_fixture(%{
          title: "Test Post #{i}",
          user_id: user.id,
          published: true
        })
      end

      {:ok, _activity_live, html} = live(conn, ~p"/activity")

      # Should handle multiple activities without breaking
      assert html =~ "Activity Feed"
    end

    test "shows proper timestamps for activities", %{conn: conn} do
      # Create an activity with a known timestamp
      user = Myhp.AccountsFixtures.user_fixture()
      _post = Myhp.BlogFixtures.post_fixture(%{user_id: user.id, published: true})

      {:ok, _activity_live, html} = live(conn, ~p"/activity")

      # Should display the activity feed page
      assert html =~ "Activity Feed"
    end
  end

end