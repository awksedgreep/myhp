defmodule MyhpWeb.AdminHTMLTest do
  use MyhpWeb.ConnCase, async: true
  import Phoenix.Template

  describe "admin HTML" do
    test "renders index template" do
      assigns = %{
        posts_count: 5,
        projects_count: 3,
        users_count: 2,
        comments_count: 10,
        messages_count: 1,
        contact_messages_count: 8,
        recent_users: [],
        recent_posts: [],
        recent_projects: []
      }
      
      html = render_to_string(MyhpWeb.AdminHTML, "index", "html", assigns)
      
      assert html =~ "Admin Dashboard"
    end
  end
end