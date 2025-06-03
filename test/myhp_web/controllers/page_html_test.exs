defmodule MyhpWeb.PageHTMLTest do
  use MyhpWeb.ConnCase, async: true
  import Phoenix.Template

  describe "page HTML" do
    test "renders home template" do
      assigns = %{
        current_user: nil,
        recent_posts: [],
        featured_projects: [],
        posts_count: 0,
        projects_count: 0
      }
      
      html = render_to_string(MyhpWeb.PageHTML, "home", "html", assigns)
      
      assert html =~ "Welcome"
    end
  end
end