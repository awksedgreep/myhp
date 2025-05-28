defmodule MyhpWeb.ComprehensiveLayoutsTest do
  use MyhpWeb.ConnCase, async: false

  describe "Layouts module comprehensive tests" do
    test "root layout renders with minimal assigns" do
      assigns = %{
        page_title: "Test Page",
        page_description: "Test description",
        current_url: "https://example.com",
        current_user: nil,
        flash: %{},
        inner_content: "Test content"
      }
      
      result = MyhpWeb.Layouts.root(assigns)
      assert result
    end

    test "root layout renders with user" do
      user = Myhp.AccountsFixtures.user_fixture()
      assigns = %{
        page_title: "Test Page",
        page_description: "Test description",
        current_url: "https://example.com",
        current_user: user,
        flash: %{},
        inner_content: "Test content"
      }
      
      result = MyhpWeb.Layouts.root(assigns)
      assert result
    end

    test "root layout renders with admin user" do
      admin_user = Myhp.AccountsFixtures.user_fixture(%{admin: true})
      assigns = %{
        page_title: "Admin Dashboard",
        page_description: "Admin description",
        current_url: "https://example.com/admin",
        current_user: admin_user,
        flash: %{},
        inner_content: "Admin content"
      }
      
      result = MyhpWeb.Layouts.root(assigns)
      assert result
    end

    test "root layout renders with flash messages" do
      assigns = %{
        page_title: "Test Page",
        page_description: "Test description",
        current_url: "https://example.com",
        current_user: nil,
        flash: %{"info" => "Success message", "error" => "Error message"},
        inner_content: "Test content"
      }
      
      result = MyhpWeb.Layouts.root(assigns)
      assert result
    end

    test "root layout renders with different page titles" do
      assigns = %{
        page_title: "Custom Title with Special Characters !@#$%",
        page_description: "Custom description with unicode 🚀",
        current_url: "https://example.com/special",
        current_user: nil,
        flash: %{},
        inner_content: "Special content"
      }
      
      result = MyhpWeb.Layouts.root(assigns)
      assert result
    end

    test "app layout renders with minimal assigns" do
      assigns = %{
        current_user: nil,
        inner_content: "Test content"
      }
      
      result = MyhpWeb.Layouts.app(assigns)
      assert result
    end

    test "app layout renders with user" do
      user = Myhp.AccountsFixtures.user_fixture()
      assigns = %{
        current_user: user,
        inner_content: "User content"
      }
      
      result = MyhpWeb.Layouts.app(assigns)
      assert result
    end

    test "app layout renders with admin user" do
      admin_user = Myhp.AccountsFixtures.user_fixture(%{admin: true})
      assigns = %{
        current_user: admin_user,
        inner_content: "Admin content"
      }
      
      result = MyhpWeb.Layouts.app(assigns)
      assert result
    end

    test "app layout renders with current page context" do
      assigns = %{
        current_user: nil,
        current_page: "blog",
        inner_content: "Blog content"
      }
      
      result = MyhpWeb.Layouts.app(assigns)
      assert result
    end

    test "app layout renders with flash messages" do
      assigns = %{
        current_user: nil,
        flash: %{"info" => "Info message", "error" => "Error message"},
        inner_content: "Content with flash"
      }
      
      result = MyhpWeb.Layouts.app(assigns)
      assert result
    end

    test "app layout renders with page title" do
      assigns = %{
        current_user: nil,
        page_title: "Custom Page Title",
        inner_content: "Titled content"
      }
      
      result = MyhpWeb.Layouts.app(assigns)
      assert result
    end

    test "app layout renders with all possible assigns" do
      user = Myhp.AccountsFixtures.user_fixture()
      assigns = %{
        current_user: user,
        current_page: "portfolio",
        page_title: "Portfolio Page",
        flash: %{"success" => "Operation completed"},
        inner_content: "Complete content"
      }
      
      result = MyhpWeb.Layouts.app(assigns)
      assert result
    end

    test "layouts handle empty inner content" do
      assigns = %{
        current_user: nil,
        inner_content: ""
      }
      
      result = MyhpWeb.Layouts.app(assigns)
      assert result
    end

    test "layouts handle nil inner content" do
      assigns = %{
        current_user: nil,
        inner_content: nil
      }
      
      result = MyhpWeb.Layouts.app(assigns)
      assert result
    end

    test "root layout handles missing optional assigns" do
      assigns = %{
        page_title: "Minimal Page",
        current_user: nil,
        flash: %{},
        inner_content: "Minimal content"
      }
      
      result = MyhpWeb.Layouts.root(assigns)
      assert result
    end
  end
end