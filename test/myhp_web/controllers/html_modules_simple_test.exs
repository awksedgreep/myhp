defmodule MyhpWeb.HTMLModulesSimpleTest do
  use MyhpWeb.ConnCase

  describe "HTML modules basic rendering" do
    test "UserConfirmationHTML edit renders" do
      conn = build_conn() |> put_params(%{"user" => %{"confirmation_token" => "test"}})
      assigns = %{conn: conn, current_user: nil, csrf_token: "test", flash: %{}}
      
      html = MyhpWeb.UserConfirmationHTML.edit(assigns)
      assert html
    end

    test "UserConfirmationHTML new renders" do
      conn = build_conn() |> put_params(%{"user" => %{}})
      assigns = %{conn: conn, current_user: nil, csrf_token: "test", flash: %{}}
      
      html = MyhpWeb.UserConfirmationHTML.new(assigns)
      assert html
    end

    test "UserRegistrationHTML new renders" do
      changeset = Myhp.Accounts.change_user_registration(%Myhp.Accounts.User{})
      conn = build_conn() |> put_params(%{"user" => %{}})
      assigns = %{conn: conn, changeset: changeset, current_user: nil, csrf_token: "test", flash: %{}}
      
      html = MyhpWeb.UserRegistrationHTML.new(assigns)
      assert html
    end

    test "UserResetPasswordHTML edit renders" do
      changeset = Myhp.Accounts.change_user_password(%Myhp.Accounts.User{})
      conn = build_conn() |> put_params(%{"user" => %{}})
      assigns = %{conn: conn, changeset: changeset, current_user: nil, csrf_token: "test", token: "test", flash: %{}}
      
      html = MyhpWeb.UserResetPasswordHTML.edit(assigns)
      assert html
    end

    test "UserResetPasswordHTML new renders" do
      conn = build_conn() |> put_params(%{"user" => %{}})
      assigns = %{conn: conn, current_user: nil, csrf_token: "test", flash: %{}}
      
      html = MyhpWeb.UserResetPasswordHTML.new(assigns)
      assert html
    end

    test "UserSessionHTML new renders" do
      conn = build_conn() |> put_params(%{"user" => %{}})
      assigns = %{conn: conn, current_user: nil, csrf_token: "test", flash: %{}, error_message: nil}
      
      html = MyhpWeb.UserSessionHTML.new(assigns)
      assert html
    end

    test "UserSettingsHTML edit renders" do
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
      
      html = MyhpWeb.UserSettingsHTML.edit(assigns)
      assert html
    end

    test "PageHTML home renders" do
      conn = build_conn() |> put_params(%{})
      assigns = %{
        conn: conn,
        current_user: nil,
        recent_posts: [],
        featured_projects: []
      }
      
      html = MyhpWeb.PageHTML.home(assigns)
      assert html
    end

    test "AdminHTML index renders" do
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
      
      html = MyhpWeb.AdminHTML.index(assigns)
      assert html
    end
  end

  defp put_params(conn, params) do
    %{conn | params: params}
  end
end