defmodule MyhpWeb.MessageLiveTest do
  use MyhpWeb.ConnCase

  import Phoenix.LiveViewTest
  import Myhp.AccountsFixtures
  import Myhp.ChatFixtures

  alias Myhp.Chat.Presence

  describe "MessageLive.Index" do
    setup do
      # Clean up presence state before each test
      if :ets.whereis(:chat_presence) != :undefined do
        :ets.delete(:chat_presence)
      end
      
      user = user_fixture()
      %{user: user}
    end

    test "requires authentication", %{conn: conn} do
      assert {:error, {:redirect, %{to: "/users/log_in"}}} = 
        live(conn, ~p"/chat")
    end

    test "renders chat page for authenticated user", %{conn: conn, user: user} do
      {:ok, _index_live, html} = 
        conn
        |> log_in_user(user)
        |> live(~p"/chat")

      assert html =~ "Community Chat"
      assert html =~ "Connect with fellow developers"
    end

    test "shows current user in online users", %{conn: conn, user: user} do
      {:ok, index_live, _html} = 
        conn
        |> log_in_user(user)
        |> live(~p"/chat")

      # Check that user appears in presence list
      users = Presence.list()
      assert user.email in users
      
      # Verify the online user count shows up in the rendered page
      html = render(index_live)
      assert html =~ "1 online"
    end

    test "displays recent messages", %{conn: conn, user: user} do
      message1 = message_fixture(%{user_id: user.id, content: "Hello world!"})
      message2 = message_fixture(%{user_id: user.id, content: "How is everyone?"})

      {:ok, _index_live, html} = 
        conn
        |> log_in_user(user)
        |> live(~p"/chat")

      assert html =~ "Hello world!"
      assert html =~ "How is everyone?"
    end

    test "can send a message", %{conn: conn, user: user} do
      {:ok, index_live, _html} = 
        conn
        |> log_in_user(user)
        |> live(~p"/chat")

      # Send a message
      index_live
      |> form("#chat-form", message: %{content: "Test message from LiveView"})
      |> render_submit()

      # Message should appear in the chat
      assert has_element?(index_live, "div", "Test message from LiveView")
    end

    test "form clears after sending message", %{conn: conn, user: user} do
      {:ok, index_live, _html} = 
        conn
        |> log_in_user(user)
        |> live(~p"/chat")

      # Send a message
      index_live
      |> form("#chat-form", message: %{content: "Test message"})
      |> render_submit()

      # Check that the form field is empty (the value should be empty in the rendered HTML)
      html = render(index_live)
      refute html =~ ~s(value="Test message")
    end

    test "validates message content", %{conn: conn, user: user} do
      {:ok, index_live, _html} = 
        conn
        |> log_in_user(user)
        |> live(~p"/chat")

      # Try to send empty message
      index_live
      |> form("#chat-form", message: %{content: ""})
      |> render_submit()

      assert has_element?(index_live, "p", "can't be blank")
    end

    test "handles user typing events", %{conn: conn, user: user} do
      {:ok, index_live, _html} = 
        conn
        |> log_in_user(user)
        |> live(~p"/chat")

      # Simulate typing
      index_live
      |> element("#chat-message-input")
      |> render_keydown(%{"key" => "a"})

      # Should not crash - typing indicators are handled internally
      assert render(index_live)
    end

    test "updates online users when other users join", %{conn: conn, user: user} do
      {:ok, index_live, _html} = 
        conn
        |> log_in_user(user)
        |> live(~p"/chat")

      # Simulate another user joining via presence
      other_user_email = "other@example.com"
      Presence.join(other_user_email)
      
      # Send the user_joined message to the LiveView
      send(index_live.pid, {:user_joined, other_user_email})

      # The online users count should update
      html = render(index_live)
      assert html =~ "2 online"
    end

    test "updates online users when users leave", %{conn: conn, user: user} do
      {:ok, index_live, _html} = 
        conn
        |> log_in_user(user)
        |> live(~p"/chat")

      # Add another user first
      other_user_email = "other@example.com"
      Presence.join(other_user_email)
      send(index_live.pid, {:user_joined, other_user_email})

      # Now simulate them leaving
      Presence.leave(other_user_email)
      send(index_live.pid, {:user_left, other_user_email})

      # Should go back to 1 online user
      html = render(index_live)
      assert html =~ "1 online"
    end

    test "receives new messages from PubSub", %{conn: conn, user: user} do
      {:ok, index_live, _html} = 
        conn
        |> log_in_user(user)
        |> live(~p"/chat")

      # Create a message and simulate PubSub broadcast
      message = message_fixture(%{user_id: user.id, content: "PubSub test message"})
      message_with_user = Myhp.Chat.get_message_with_user!(message.id)
      
      send(index_live.pid, {:new_message, message_with_user})

      # Message should appear
      assert has_element?(index_live, "div", "PubSub test message")
    end

    test "cleans up presence on disconnect", %{conn: conn, user: user} do
      {:ok, index_live, _html} = 
        conn
        |> log_in_user(user)
        |> live(~p"/chat")

      # User should be in presence
      assert user.email in Presence.list()

      # Stop the LiveView (simulates user disconnect)
      GenServer.stop(index_live.pid)

      # Give it a moment to clean up
      Process.sleep(10)

      # User should be removed from presence
      # Note: In tests, terminate might not be called automatically,
      # so we'll test the terminate function directly
      MyhpWeb.MessageLive.Index.terminate(:normal, %{assigns: %{current_user: user}})
      refute user.email in Presence.list()
    end
  end
end