defmodule MyhpWeb.Admin.UserLive do
  use MyhpWeb, :live_view

  alias Myhp.Accounts

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "User Management")
     |> assign(:current_page, "admin")
     |> load_users()}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "User Management")
    |> assign(:user, nil)
  end

  defp apply_action(socket, :show, %{"id" => id}) do
    user = Accounts.get_user!(id)

    socket
    |> assign(:page_title, "User Details")
    |> assign(:user, user)
  end

  @impl true
  def handle_event("ban_user", %{"id" => id}, socket) do
    user = Accounts.get_user!(id)

    case Accounts.ban_user(user) do
      {:ok, _user} ->
        {:noreply,
         socket
         |> put_flash(:info, "User has been banned successfully.")
         |> load_users()}

      {:error, _changeset} ->
        {:noreply, put_flash(socket, :error, "Failed to ban user.")}
    end
  end

  def handle_event("unban_user", %{"id" => id}, socket) do
    user = Accounts.get_user!(id)

    case Accounts.unban_user(user) do
      {:ok, _user} ->
        {:noreply,
         socket
         |> put_flash(:info, "User has been unbanned successfully.")
         |> load_users()}

      {:error, _changeset} ->
        {:noreply, put_flash(socket, :error, "Failed to unban user.")}
    end
  end

  def handle_event("delete_user", %{"id" => id}, socket) do
    user = Accounts.get_user!(id)

    # Prevent deleting the current admin user
    if user.id == socket.assigns.current_user.id do
      {:noreply, put_flash(socket, :error, "You cannot delete your own account.")}
    else
      case Accounts.delete_user(user) do
        {:ok, _user} ->
          {:noreply,
           socket
           |> put_flash(:info, "User has been deleted successfully.")
           |> load_users()}

        {:error, _changeset} ->
          {:noreply, put_flash(socket, :error, "Failed to delete user.")}
      end
    end
  end

  def handle_event("promote_user", %{"id" => id}, socket) do
    user = Accounts.get_user!(id)

    case Accounts.promote_to_admin(user) do
      {:ok, _user} ->
        {:noreply,
         socket
         |> put_flash(:info, "User has been promoted to admin.")
         |> load_users()}

      {:error, _changeset} ->
        {:noreply, put_flash(socket, :error, "Failed to promote user.")}
    end
  end

  def handle_event("demote_user", %{"id" => id}, socket) do
    user = Accounts.get_user!(id)

    # Prevent demoting the current admin user
    if user.id == socket.assigns.current_user.id do
      {:noreply, put_flash(socket, :error, "You cannot demote your own account.")}
    else
      case Accounts.demote_from_admin(user) do
        {:ok, _user} ->
          {:noreply,
           socket
           |> put_flash(:info, "User has been demoted from admin.")
           |> load_users()}

        {:error, _changeset} ->
          {:noreply, put_flash(socket, :error, "Failed to demote user.")}
      end
    end
  end

  defp load_users(socket) do
    users = Accounts.list_users_with_stats()
    assign(socket, :users, users)
  end

  defp user_status_badge(user) do
    cond do
      user.banned_at -> "bg-red-100 text-red-800 dark:bg-red-900/30 dark:text-red-300"
      user.confirmed_at -> "bg-green-100 text-green-800 dark:bg-green-900/30 dark:text-green-300"
      true -> "bg-yellow-100 text-yellow-800 dark:bg-yellow-900/30 dark:text-yellow-300"
    end
  end

  defp user_status_text(user) do
    cond do
      user.banned_at -> "Banned"
      user.confirmed_at -> "Active"
      true -> "Unconfirmed"
    end
  end

  defp user_role_badge(user) do
    if user.admin do
      "bg-purple-100 text-purple-800 dark:bg-purple-900/30 dark:text-purple-300"
    else
      "bg-gray-100 text-gray-800 dark:bg-gray-900/30 dark:text-gray-300"
    end
  end

  defp user_role_text(user) do
    if user.admin, do: "Admin", else: "User"
  end
end
