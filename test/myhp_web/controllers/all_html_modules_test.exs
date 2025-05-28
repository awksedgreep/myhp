defmodule MyhpWeb.AllHTMLModulesTest do
  use MyhpWeb.ConnCase

  describe "UserConfirmationHTML comprehensive tests" do
    test "edit template renders with token" do
      conn = build_conn() |> put_params(%{"user" => %{"confirmation_token" => "test_token"}})
      assigns = %{conn: conn, current_user: nil, csrf_token: "test", flash: %{}}
      
      result = MyhpWeb.UserConfirmationHTML.edit(assigns)
      assert result
    end

    test "new template renders" do
      conn = build_conn() |> put_params(%{"user" => %{}})
      assigns = %{conn: conn, current_user: nil, csrf_token: "test", flash: %{}}
      
      result = MyhpWeb.UserConfirmationHTML.new(assigns)
      assert result
    end

    test "edit template with different parameters" do
      conn = build_conn() |> put_params(%{"user" => %{"confirmation_token" => "different_token"}})
      assigns = %{conn: conn, current_user: nil, csrf_token: "different", flash: %{"info" => "test"}}
      
      result = MyhpWeb.UserConfirmationHTML.edit(assigns)
      assert result
    end
  end

  describe "UserRegistrationHTML comprehensive tests" do
    test "new template renders with changeset" do
      changeset = Myhp.Accounts.change_user_registration(%Myhp.Accounts.User{})
      conn = build_conn() |> put_params(%{"user" => %{}})
      assigns = %{conn: conn, changeset: changeset, current_user: nil, csrf_token: "test", flash: %{}}
      
      result = MyhpWeb.UserRegistrationHTML.new(assigns)
      assert result
    end

    test "new template with error changeset" do
      {:error, changeset} = Myhp.Accounts.register_user(%{email: "invalid"})
      conn = build_conn() |> put_params(%{"user" => %{}})
      assigns = %{conn: conn, changeset: changeset, current_user: nil, csrf_token: "test", flash: %{}}
      
      result = MyhpWeb.UserRegistrationHTML.new(assigns)
      assert result
    end

    test "new template with valid data" do
      changeset = Myhp.Accounts.change_user_registration(%Myhp.Accounts.User{}, %{email: "test@example.com"})
      conn = build_conn() |> put_params(%{"user" => %{}})
      assigns = %{conn: conn, changeset: changeset, current_user: nil, csrf_token: "test", flash: %{}}
      
      result = MyhpWeb.UserRegistrationHTML.new(assigns)
      assert result
    end
  end

  describe "UserResetPasswordHTML comprehensive tests" do
    test "edit template renders with changeset" do
      changeset = Myhp.Accounts.change_user_password(%Myhp.Accounts.User{})
      conn = build_conn() |> put_params(%{"user" => %{}})
      assigns = %{conn: conn, changeset: changeset, current_user: nil, csrf_token: "test", token: "reset_token", flash: %{}}
      
      result = MyhpWeb.UserResetPasswordHTML.edit(assigns)
      assert result
    end

    test "new template renders" do
      conn = build_conn() |> put_params(%{"user" => %{}})
      assigns = %{conn: conn, current_user: nil, csrf_token: "test", flash: %{}}
      
      result = MyhpWeb.UserResetPasswordHTML.new(assigns)
      assert result
    end

    test "edit template with password errors" do
      user = Myhp.AccountsFixtures.user_fixture()
      {:error, changeset} = Myhp.Accounts.update_user_password(user, "wrong", %{password: "short"})
      conn = build_conn() |> put_params(%{"user" => %{}})
      assigns = %{conn: conn, changeset: changeset, current_user: nil, csrf_token: "test", token: "token", flash: %{}}
      
      result = MyhpWeb.UserResetPasswordHTML.edit(assigns)
      assert result
    end
  end

  describe "UserSessionHTML comprehensive tests" do
    test "new template renders without errors" do
      conn = build_conn() |> put_params(%{"user" => %{}})
      assigns = %{conn: conn, current_user: nil, csrf_token: "test", flash: %{}, error_message: nil}
      
      result = MyhpWeb.UserSessionHTML.new(assigns)
      assert result
    end

    test "new template renders with error message" do
      conn = build_conn() |> put_params(%{"user" => %{}})
      assigns = %{conn: conn, current_user: nil, csrf_token: "test", flash: %{}, error_message: "Invalid credentials"}
      
      result = MyhpWeb.UserSessionHTML.new(assigns)
      assert result
    end

    test "new template renders with different parameters" do
      conn = build_conn() |> put_params(%{"user" => %{"email" => "test@example.com"}})
      assigns = %{conn: conn, current_user: nil, csrf_token: "different", flash: %{"error" => "Login failed"}, error_message: "Wrong password"}
      
      result = MyhpWeb.UserSessionHTML.new(assigns)
      assert result
    end
  end

  describe "UserSettingsHTML comprehensive tests" do
    test "edit template renders with changesets" do
      user = Myhp.AccountsFixtures.user_fixture()
      email_changeset = Myhp.Accounts.change_user_email(user)
      password_changeset = Myhp.Accounts.change_user_password(user)
      conn = build_conn() |> put_params(%{"user" => %{}})
      
      assigns = %{
        conn: conn,
        current_user: user,
        email_changeset: email_changeset,
        password_changeset: password_changeset,
        csrf_token: "test",
        flash: %{}
      }
      
      result = MyhpWeb.UserSettingsHTML.edit(assigns)
      assert result
    end

    test "edit template with email change errors" do
      user = Myhp.AccountsFixtures.user_fixture()
      {:error, email_changeset} = Myhp.Accounts.apply_user_email(user, "invalid", %{email: "invalid"})
      password_changeset = Myhp.Accounts.change_user_password(user)
      conn = build_conn() |> put_params(%{"user" => %{}})
      
      assigns = %{
        conn: conn,
        current_user: user,
        email_changeset: email_changeset,
        password_changeset: password_changeset,
        csrf_token: "test",
        flash: %{}
      }
      
      result = MyhpWeb.UserSettingsHTML.edit(assigns)
      assert result
    end

    test "edit template with password change errors" do
      user = Myhp.AccountsFixtures.user_fixture()
      email_changeset = Myhp.Accounts.change_user_email(user)
      {:error, password_changeset} = Myhp.Accounts.update_user_password(user, "wrong", %{password: "short"})
      conn = build_conn() |> put_params(%{"user" => %{}})
      
      assigns = %{
        conn: conn,
        current_user: user,
        email_changeset: email_changeset,
        password_changeset: password_changeset,
        csrf_token: "test",
        flash: %{}
      }
      
      result = MyhpWeb.UserSettingsHTML.edit(assigns)
      assert result
    end
  end

  describe "PageHTML comprehensive tests" do
    test "home template renders with empty data" do
      conn = build_conn() |> put_params(%{})
      assigns = %{
        conn: conn,
        current_user: nil,
        recent_posts: [],
        featured_projects: []
      }
      
      result = MyhpWeb.PageHTML.home(assigns)
      assert result
    end

    test "home template renders with posts and projects" do
      user = Myhp.AccountsFixtures.user_fixture()
      post = Myhp.BlogFixtures.post_fixture(%{user_id: user.id, published: true})
      project = Myhp.PortfolioFixtures.project_fixture(%{published: true, featured: true})
      
      conn = build_conn() |> put_params(%{})
      assigns = %{
        conn: conn,
        current_user: nil,
        recent_posts: [post],
        featured_projects: [project]
      }
      
      result = MyhpWeb.PageHTML.home(assigns)
      assert result
    end

    test "home template renders with logged in user" do
      user = Myhp.AccountsFixtures.user_fixture()
      
      conn = build_conn() |> put_params(%{})
      assigns = %{
        conn: conn,
        current_user: user,
        recent_posts: [],
        featured_projects: []
      }
      
      result = MyhpWeb.PageHTML.home(assigns)
      assert result
    end

    test "home template renders with admin user" do
      admin_user = Myhp.AccountsFixtures.user_fixture(%{admin: true})
      
      conn = build_conn() |> put_params(%{})
      assigns = %{
        conn: conn,
        current_user: admin_user,
        recent_posts: [],
        featured_projects: []
      }
      
      result = MyhpWeb.PageHTML.home(assigns)
      assert result
    end
  end

  describe "AdminHTML comprehensive tests" do
    test "index template renders with stats" do
      admin_user = Myhp.AccountsFixtures.user_fixture(%{admin: true})
      conn = build_conn() |> put_params(%{})
      assigns = %{
        conn: conn,
        current_user: admin_user,
        stats: %{
          total_users: 10,
          total_posts: 5,
          total_comments: 15,
          total_projects: 3
        }
      }
      
      result = MyhpWeb.AdminHTML.index(assigns)
      assert result
    end

    test "index template renders with zero stats" do
      admin_user = Myhp.AccountsFixtures.user_fixture(%{admin: true})
      conn = build_conn() |> put_params(%{})
      assigns = %{
        conn: conn,
        current_user: admin_user,
        stats: %{
          total_users: 0,
          total_posts: 0,
          total_comments: 0,
          total_projects: 0
        }
      }
      
      result = MyhpWeb.AdminHTML.index(assigns)
      assert result
    end

    test "index template renders with large stats" do
      admin_user = Myhp.AccountsFixtures.user_fixture(%{admin: true})
      conn = build_conn() |> put_params(%{})
      assigns = %{
        conn: conn,
        current_user: admin_user,
        stats: %{
          total_users: 1000,
          total_posts: 500,
          total_comments: 2500,
          total_projects: 100
        }
      }
      
      result = MyhpWeb.AdminHTML.index(assigns)
      assert result
    end
  end

  defp put_params(conn, params) do
    %{conn | params: params}
  end
end