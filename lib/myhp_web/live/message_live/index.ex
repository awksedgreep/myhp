defmodule MyhpWeb.MessageLive.Index do
  use MyhpWeb, :live_view
  alias Myhp.Chat
  alias Myhp.Chat.Message
  alias Myhp.Chat.Presence

  @topic "chat:lobby"

  @impl true
  def mount(_params, _session, socket) do
    current_user = socket.assigns[:current_user]
    
    if connected?(socket) do
      Phoenix.PubSub.subscribe(Myhp.PubSub, @topic)

      # Track user presence
      if current_user do
        Presence.join(current_user.email)
        Phoenix.PubSub.broadcast(
          Myhp.PubSub,
          @topic,
          {:user_joined, current_user.email}
        )
      end
    end

    messages = Chat.list_recent_messages(50)

    {:ok,
     socket
     |> assign(:current_user, current_user)
     |> assign(:page_title, "Community Chat")
     |> assign(:messages, messages)
     |> assign(:message_form, to_form(Chat.change_message(%Message{})))
     |> assign(:online_users, Presence.list())
     |> assign(:typing_users, %{})}
  end

  @impl true
  def handle_event("send_message", %{"message" => message_params}, socket) do
    current_user = socket.assigns.current_user

    message_params = Map.put(message_params, "user_id", current_user.id)

    case Chat.create_message(message_params) do
      {:ok, message} ->
        message_with_user = Chat.get_message_with_user!(message.id)

        # Broadcast to chat
        Phoenix.PubSub.broadcast(
          Myhp.PubSub,
          @topic,
          {:new_message, message_with_user}
        )

        # Broadcast notification to all users
        Phoenix.PubSub.broadcast(
          Myhp.PubSub,
          "notifications:all",
          {:new_message, message_with_user}
        )

        # Create a fresh form to clear the input
        fresh_changeset = Chat.change_message(%Message{})
        
        {:noreply,
         socket
         |> assign(:message_form, to_form(fresh_changeset))
         |> push_event("clear-form", %{})}

      {:error, changeset} ->
        {:noreply, assign(socket, :message_form, to_form(changeset))}
    end
  end

  @impl true
  def handle_event("user_typing", %{"key" => "Enter"}, socket) do
    # Don't broadcast typing on Enter key
    {:noreply, socket}
  end

  def handle_event("user_typing", _params, socket) do
    current_user = socket.assigns.current_user

    Phoenix.PubSub.broadcast(
      Myhp.PubSub,
      @topic,
      {:user_typing, current_user.email}
    )

    {:noreply, socket}
  end

  @impl true
  def handle_event("user_stopped_typing", _params, socket) do
    current_user = socket.assigns.current_user

    Phoenix.PubSub.broadcast(
      Myhp.PubSub,
      @topic,
      {:user_stopped_typing, current_user.email}
    )

    {:noreply, socket}
  end

  @impl true
  def handle_info({:new_message, message}, socket) do
    # Keep only last 100 messages to prevent memory issues
    {:noreply,
     socket
     |> update(:messages, fn messages ->
       (messages ++ [message])
       |> Enum.take(-100)
     end)
     |> push_event("scroll_to_bottom", %{})}
  end

  @impl true
  def handle_info({:user_typing, user_email}, socket) do
    if user_email != socket.assigns.current_user.email do
      typing_users = Map.put(socket.assigns.typing_users, user_email, DateTime.utc_now())
      {:noreply, assign(socket, :typing_users, typing_users)}
    else
      {:noreply, socket}
    end
  end

  @impl true
  def handle_info({:user_stopped_typing, user_email}, socket) do
    typing_users = Map.delete(socket.assigns.typing_users, user_email)
    {:noreply, assign(socket, :typing_users, typing_users)}
  end

  @impl true
  def handle_info({:user_joined, _user_email}, socket) do
    # Refresh the online users list from the global state
    {:noreply, assign(socket, :online_users, Presence.list())}
  end

  @impl true
  def handle_info({:user_left, _user_email}, socket) do
    # Refresh the online users list from the global state
    {:noreply, assign(socket, :online_users, Presence.list())}
  end

  @impl true
  def terminate(_reason, socket) do
    current_user = socket.assigns[:current_user]
    if current_user do
      Presence.leave(current_user.email)
      Phoenix.PubSub.broadcast(
        Myhp.PubSub,
        @topic,
        {:user_left, current_user.email}
      )
    end
    :ok
  end


  defp get_user_initial(user) do
    case user do
      %{email: email} when is_binary(email) -> 
        String.at(email, 0) |> String.upcase()
      string when is_binary(string) -> 
        String.at(string, 0) |> String.upcase()
      _ -> "?"
    end
  end

  defp get_user_display(user) do
    case user do
      %{email: email} when is_binary(email) -> email
      string when is_binary(string) -> string
      _ -> "Unknown User"
    end
  end

  defp get_message_time(message) do
    case message do
      %{inserted_at: inserted_at} when not is_nil(inserted_at) ->
        now = DateTime.utc_now()
        message_time = DateTime.from_naive!(inserted_at, "Etc/UTC")
        diff = DateTime.diff(now, message_time, :second)

        cond do
          diff < 60 -> "just now"
          diff < 3600 -> "#{div(diff, 60)}m ago"
          diff < 86400 -> "#{div(diff, 3600)}h ago"
          true -> Calendar.strftime(message_time, "%b %d at %I:%M %p")
        end
      _ -> "just now"
    end
  end
end
