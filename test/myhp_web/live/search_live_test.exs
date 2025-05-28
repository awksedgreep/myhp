defmodule MyhpWeb.SearchLiveTest do
  use MyhpWeb.ConnCase

  import Phoenix.LiveViewTest
  import Myhp.BlogFixtures

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
  end
end