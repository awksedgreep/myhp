defmodule MyhpWeb.AdminControllerTest do
  use MyhpWeb.ConnCase
  alias Myhp.Accounts

  setup %{conn: conn} do
    admin_user = Myhp.AccountsFixtures.user_fixture(%{admin: true})
    regular_user = Myhp.AccountsFixtures.user_fixture(%{admin: false})
    
    admin_conn = log_in_user(conn, admin_user)
    user_conn = log_in_user(conn, regular_user)
    
    %{
      conn: conn,
      admin_conn: admin_conn, 
      user_conn: user_conn,
      admin_user: admin_user,
      regular_user: regular_user
    }
  end

  describe "GET /admin" do
    test "renders admin dashboard for admin users", %{admin_conn: conn, admin_user: admin_user} do
      # Debug: ensure admin user is actually admin
      assert admin_user.admin == true
      conn = get(conn, ~p"/admin")
      assert html_response(conn, 200) =~ "Admin Dashboard"
    end

    test "redirects non-admin users", %{user_conn: conn} do
      conn = get(conn, ~p"/admin")
      assert redirected_to(conn) == ~p"/"
    end

    test "redirects unauthenticated users", %{conn: conn} do
      conn = get(conn, ~p"/admin")
      assert redirected_to(conn) == ~p"/users/log_in"
    end
  end

  describe "POST /admin/users/:id/toggle_admin" do
    test "allows admin to promote user to admin", %{admin_conn: conn, regular_user: user} do
      conn = post(conn, ~p"/admin/users/#{user.id}/toggle_admin")
      
      assert redirected_to(conn) == ~p"/admin"
      assert Phoenix.Flash.get(conn.assigns.flash, :info) =~ "User admin status updated"
      
      updated_user = Accounts.get_user!(user.id)
      assert updated_user.admin == true
    end

    test "allows admin to demote admin user", %{admin_conn: conn} do
      admin_user = Myhp.AccountsFixtures.user_fixture(%{admin: true})
      
      conn = post(conn, ~p"/admin/users/#{admin_user.id}/toggle_admin")
      
      assert redirected_to(conn) == ~p"/admin"
      updated_user = Accounts.get_user!(admin_user.id)
      assert updated_user.admin == false
    end

    test "prevents non-admin from toggling admin status", %{user_conn: conn, regular_user: user} do
      conn = post(conn, ~p"/admin/users/#{user.id}/toggle_admin")
      assert redirected_to(conn) == ~p"/"
    end
  end

  describe "POST /admin/users/:id/ban" do
    test "allows admin to ban user", %{admin_conn: conn, regular_user: user} do
      conn = post(conn, ~p"/admin/users/#{user.id}/ban")
      
      assert redirected_to(conn) == ~p"/admin"
      assert Phoenix.Flash.get(conn.assigns.flash, :info) =~ "User banned successfully"
      
      updated_user = Accounts.get_user!(user.id)
      assert updated_user.banned_at != nil
    end

    test "prevents non-admin from banning users", %{user_conn: conn, regular_user: user} do
      conn = post(conn, ~p"/admin/users/#{user.id}/ban")
      assert redirected_to(conn) == ~p"/"
    end
  end

  describe "POST /admin/users/:id/unban" do
    test "allows admin to unban user", %{admin_conn: conn} do
      banned_user = Myhp.AccountsFixtures.user_fixture(%{
        banned_at: DateTime.utc_now() |> DateTime.truncate(:second)
      })
      
      conn = post(conn, ~p"/admin/users/#{banned_user.id}/unban")
      
      assert redirected_to(conn) == ~p"/admin"
      assert Phoenix.Flash.get(conn.assigns.flash, :info) =~ "User unbanned successfully"
      
      updated_user = Accounts.get_user!(banned_user.id)
      assert updated_user.banned_at == nil
    end

    test "prevents non-admin from unbanning users", %{user_conn: conn} do
      banned_user = Myhp.AccountsFixtures.user_fixture(%{
        banned_at: DateTime.utc_now() |> DateTime.truncate(:second)
      })
      
      conn = post(conn, ~p"/admin/users/#{banned_user.id}/unban")
      assert redirected_to(conn) == ~p"/"
    end
  end

  describe "DELETE /admin/users/:id" do
    test "allows admin to delete user", %{admin_conn: conn, regular_user: user} do
      conn = delete(conn, ~p"/admin/users/#{user.id}")
      
      assert redirected_to(conn) == ~p"/admin"
      assert Phoenix.Flash.get(conn.assigns.flash, :info) =~ "User deleted successfully"
      
      assert_raise Ecto.NoResultsError, fn ->
        Accounts.get_user!(user.id)
      end
    end

    test "prevents admin from deleting themselves", %{admin_conn: conn, admin_user: admin} do
      conn = delete(conn, ~p"/admin/users/#{admin.id}")
      
      assert redirected_to(conn) == ~p"/admin"
      assert Phoenix.Flash.get(conn.assigns.flash, :error) =~ "Cannot delete yourself"
      
      # User should still exist
      assert Accounts.get_user!(admin.id)
    end

    test "prevents non-admin from deleting users", %{user_conn: conn, regular_user: user} do
      conn = delete(conn, ~p"/admin/users/#{user.id}")
      assert redirected_to(conn) == ~p"/"
    end
  end

  describe "admin dashboard data" do
    test "shows user statistics", %{admin_conn: conn} do
      # Create some test data
      Myhp.AccountsFixtures.user_fixture(%{admin: true})
      Myhp.AccountsFixtures.user_fixture(%{banned_at: DateTime.utc_now() |> DateTime.truncate(:second)})
      
      conn = get(conn, ~p"/admin")
      response = html_response(conn, 200)
      
      assert response =~ "Total Users"
      assert response =~ "Chat Messages"
      assert response =~ "Contact Messages"
    end

    test "shows content statistics", %{admin_conn: conn} do
      user = Myhp.AccountsFixtures.user_fixture()
      Myhp.BlogFixtures.post_fixture(%{user_id: user.id, published: true})
      Myhp.BlogFixtures.post_fixture(%{user_id: user.id, published: false})
      Myhp.PortfolioFixtures.project_fixture()
      
      conn = get(conn, ~p"/admin")
      response = html_response(conn, 200)
      
      assert response =~ "Published Posts"
      assert response =~ "Comments"
      assert response =~ "Projects"
    end
  end
end