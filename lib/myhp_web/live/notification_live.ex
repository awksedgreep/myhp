defmodule MyhpWeb.NotificationLive do
  use MyhpWeb, :live_view

  alias Myhp.Chat
  alias Phoenix.PubSub

  @impl true
  def mount(_params, _session, socket) do
    user = socket.assigns[:current_user]

    if connected?(socket) do
      PubSub.subscribe(Myhp.PubSub, "notifications:all")
      PubSub.subscribe(Myhp.PubSub, "system_notifications")
    end

    notifications = if user, do: get_recent_notifications(user.id), else: []

    {:ok,
     socket
     |> assign(:user, user)
     |> assign(:notifications, notifications)
     |> assign(:unread_count, count_unread_notifications(notifications))}
  end

  @impl true
  def handle_info({:new_comment, comment}, socket) do
    notification = %{
      id: "comment_#{comment.id}",
      type: :comment,
      title: "New comment on your post",
      message: "#{comment.user.email} commented: #{String.slice(comment.content, 0, 50)}...",
      timestamp: comment.inserted_at,
      read: false,
      data: comment
    }

    notifications = [notification | socket.assigns.notifications] |> Enum.take(20)

    {:noreply,
     socket
     |> assign(:notifications, notifications)
     |> assign(:unread_count, socket.assigns.unread_count + 1)
     |> put_flash(:info, "New comment on your post!")}
  end

  @impl true
  def handle_info({:new_message, message}, socket) do
    notification = %{
      id: "message_#{message.id}",
      type: :message,
      title: "New chat message",
      message: "#{message.user.email}: #{String.slice(message.content, 0, 50)}...",
      timestamp: message.inserted_at,
      read: false,
      data: message
    }

    notifications = [notification | socket.assigns.notifications] |> Enum.take(20)

    {:noreply,
     socket
     |> assign(:notifications, notifications)
     |> assign(:unread_count, socket.assigns.unread_count + 1)}
  end

  @impl true
  def handle_info({:system_notification, notification}, socket) do
    notifications = [notification | socket.assigns.notifications] |> Enum.take(20)

    {:noreply,
     socket
     |> assign(:notifications, notifications)
     |> assign(:unread_count, socket.assigns.unread_count + 1)
     |> put_flash(:info, notification.message)}
  end

  @impl true
  def handle_info({:new_notification, notification}, socket) do
    formatted_notification = %{
      id: "test_#{System.unique_integer([:positive])}",
      type: notification[:type] || :system,
      title: notification[:title] || "Test Notification",
      message: notification[:message] || "Test notification message",
      timestamp: NaiveDateTime.utc_now(),
      read: notification[:read] || false,
      data: notification[:data] || %{}
    }

    notifications = [formatted_notification | socket.assigns.notifications] |> Enum.take(20)

    {:noreply,
     socket
     |> assign(:notifications, notifications)
     |> assign(:unread_count, socket.assigns.unread_count + 1)}
  end

  @impl true
  def handle_info(_message, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event("mark_read", %{"id" => notification_id}, socket) do
    notifications =
      Enum.map(socket.assigns.notifications, fn notification ->
        if notification.id == notification_id do
          %{notification | read: true}
        else
          notification
        end
      end)

    unread_count = count_unread_notifications(notifications)

    {:noreply,
     socket
     |> assign(:notifications, notifications)
     |> assign(:unread_count, unread_count)}
  end

  @impl true
  def handle_event("mark_all_read", _params, socket) do
    notifications =
      Enum.map(socket.assigns.notifications, fn notification ->
        %{notification | read: true}
      end)

    {:noreply,
     socket
     |> assign(:notifications, notifications)
     |> assign(:unread_count, 0)}
  end

  @impl true
  def handle_event("clear_notifications", _params, socket) do
    {:noreply,
     socket
     |> assign(:notifications, [])
     |> assign(:unread_count, 0)}
  end

  defp get_recent_notifications(_user_id) do
    recent_messages =
      Chat.list_messages()
      |> Enum.take(5)
      |> Enum.map(fn message ->
        %{
          id: "message_#{message.id}",
          type: :message,
          title: "Chat message",
          message: "#{message.user.email}: #{String.slice(message.content, 0, 50)}...",
          timestamp: message.inserted_at,
          read: true,
          data: message
        }
      end)

    recent_messages
    |> Enum.sort_by(& &1.timestamp, {:desc, NaiveDateTime})
    |> Enum.take(10)
  end

  defp count_unread_notifications(notifications) do
    Enum.count(notifications, &(!&1.read))
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="max-w-4xl mx-auto p-6">
      <div class="flex justify-between items-center mb-6">
        <h1 class="text-3xl font-bold text-gray-900">Notifications</h1>
        <div class="flex space-x-2">
          <button
            phx-click="mark_all_read"
            class="px-4 py-2 bg-blue-600 text-white rounded-md hover:bg-blue-700"
          >
            Mark All Read
          </button>
          <button
            phx-click="clear_notifications"
            class="px-4 py-2 bg-red-600 text-white rounded-md hover:bg-red-700"
          >
            Clear All
          </button>
        </div>
      </div>

      <div class="mb-4 p-3 bg-blue-50 rounded-lg">
        <p class="text-sm text-blue-800">
          <span class="font-semibold">{@unread_count}</span> unread notifications
        </p>
      </div>

      <div class="space-y-4">
        <%= for notification <- @notifications do %>
          <div class={[
            "p-4 border rounded-lg transition-colors",
            if(notification.read,
              do: "bg-gray-50 border-gray-200",
              else: "bg-white border-blue-200 shadow-sm"
            )
          ]}>
            <div class="flex justify-between items-start">
              <div class="flex-1">
                <div class="flex items-center space-x-2">
                  <span class={[
                    "inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium",
                    case notification.type do
                      :comment -> "bg-green-100 text-green-800"
                      :message -> "bg-blue-100 text-blue-800"
                      :system -> "bg-yellow-100 text-yellow-800"
                      _ -> "bg-gray-100 text-gray-800"
                    end
                  ]}>
                    {String.capitalize(to_string(notification.type))}
                  </span>
                  <h3 class="text-sm font-medium text-gray-900">
                    {notification.title}
                  </h3>
                  <%= unless notification.read do %>
                    <span class="w-2 h-2 bg-blue-600 rounded-full"></span>
                  <% end %>
                </div>
                <p class="mt-1 text-sm text-gray-600">
                  {notification.message}
                </p>
                <p class="mt-1 text-xs text-gray-500">
                  {Calendar.strftime(notification.timestamp, "%B %d, %Y at %I:%M %p")}
                </p>
              </div>
              <%= unless notification.read do %>
                <button
                  phx-click="mark_read"
                  phx-value-id={notification.id}
                  class="ml-4 text-sm text-blue-600 hover:text-blue-800"
                >
                  Mark Read
                </button>
              <% end %>
            </div>
          </div>
        <% end %>

        <%= if Enum.empty?(@notifications) do %>
          <div class="text-center py-8">
            <p class="text-gray-500">No notifications yet.</p>
          </div>
        <% end %>
      </div>
    </div>
    """
  end
end
