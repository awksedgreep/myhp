defmodule MyhpWeb.AdminController do
  use MyhpWeb, :controller
  
  alias Myhp.Accounts

  plug :require_admin

  def index(conn, _params) do
    # Get some basic stats for the dashboard
    posts_count = Myhp.Blog.count_posts()
    comments_count = Myhp.Blog.count_comments()
    projects_count = Myhp.Portfolio.count_projects()
    users_count = Myhp.Accounts.count_users()
    messages_count = Myhp.Chat.count_messages()
    contact_messages_count = Myhp.Contact.count_contact_messages()
    uploaded_files_count = Myhp.Uploads.count_uploaded_files()

    render(conn, :index,
      posts_count: posts_count,
      comments_count: comments_count,
      projects_count: projects_count,
      users_count: users_count,
      messages_count: messages_count,
      contact_messages_count: contact_messages_count,
      uploaded_files_count: uploaded_files_count,
      page_title: "Admin Dashboard"
    )
  end

  def toggle_admin(conn, %{"id" => user_id}) do
    user = Accounts.get_user!(user_id)
    
    case Accounts.update_user(user, %{admin: !user.admin}) do
      {:ok, _user} ->
        conn
        |> put_flash(:info, "User admin status updated successfully.")
        |> redirect(to: ~p"/admin")
      {:error, _changeset} ->
        conn
        |> put_flash(:error, "Failed to update user admin status.")
        |> redirect(to: ~p"/admin")
    end
  end

  def ban_user(conn, %{"id" => user_id}) do
    user = Accounts.get_user!(user_id)
    banned_at = DateTime.utc_now() |> DateTime.truncate(:second)
    
    case Accounts.update_user(user, %{banned_at: banned_at}) do
      {:ok, _user} ->
        conn
        |> put_flash(:info, "User banned successfully.")
        |> redirect(to: ~p"/admin")
      {:error, _changeset} ->
        conn
        |> put_flash(:error, "Failed to ban user.")
        |> redirect(to: ~p"/admin")
    end
  end

  def unban_user(conn, %{"id" => user_id}) do
    user = Accounts.get_user!(user_id)
    
    case Accounts.update_user(user, %{banned_at: nil}) do
      {:ok, _user} ->
        conn
        |> put_flash(:info, "User unbanned successfully.")
        |> redirect(to: ~p"/admin")
      {:error, _changeset} ->
        conn
        |> put_flash(:error, "Failed to unban user.")
        |> redirect(to: ~p"/admin")
    end
  end

  def delete_user(conn, %{"id" => user_id}) do
    current_user = conn.assigns.current_user
    
    if current_user.id == String.to_integer(user_id) do
      conn
      |> put_flash(:error, "Cannot delete yourself.")
      |> redirect(to: ~p"/admin")
    else
      user = Accounts.get_user!(user_id)
      
      case Accounts.delete_user(user) do
        {:ok, _user} ->
          conn
          |> put_flash(:info, "User deleted successfully.")
          |> redirect(to: ~p"/admin")
        {:error, _changeset} ->
          conn
          |> put_flash(:error, "Failed to delete user.")
          |> redirect(to: ~p"/admin")
      end
    end
  end

  defp require_admin(conn, _opts) do
    case conn.assigns[:current_user] do
      %{admin: true} -> conn
      _ ->
        conn
        |> put_flash(:error, "Access denied. Admin privileges required.")
        |> redirect(to: ~p"/")
        |> halt()
    end
  end
end
