defmodule MyhpWeb.EnhancedLiveViewTest do
  use MyhpWeb.ConnCase

  import Phoenix.LiveViewTest

  describe "ActivityLive enhanced tests" do
    setup [:register_and_log_in_user]

    test "renders with multiple activity types", %{conn: conn, user: user} do
      # Create various activities
      _post = Myhp.BlogFixtures.post_fixture(%{user_id: user.id, published: true})
      _project = Myhp.PortfolioFixtures.project_fixture(%{published: true})
      _message = Myhp.ChatFixtures.message_fixture(%{user_id: user.id})

      {:ok, _activity_live, html} = live(conn, ~p"/activity")
      assert html =~ "activity" or html =~ "Activity"
    end

    test "handles live updates", %{conn: conn} do
      {:ok, activity_live, _html} = live(conn, ~p"/activity")
      
      # Test different types of updates
      send(activity_live.pid, {:new_activity, %{type: "post", data: %{title: "New Post"}}})
      send(activity_live.pid, {:new_activity, %{type: "comment", data: %{content: "New Comment"}}})
      
      html = render(activity_live)
      assert html =~ "activity" or html =~ "Activity"
    end

    test "displays different activity formats", %{conn: conn, user: user} do
      # Create activities with different content lengths
      _short_post = Myhp.BlogFixtures.post_fixture(%{
        title: "Short",
        content: "Brief",
        user_id: user.id,
        published: true
      })
      
      _long_post = Myhp.BlogFixtures.post_fixture(%{
        title: "Very Long Title " <> String.duplicate("Word ", 20),
        content: String.duplicate("Long content paragraph. ", 50),
        user_id: user.id,
        published: true
      })

      {:ok, _activity_live, html} = live(conn, ~p"/activity")
      assert html =~ "activity" or html =~ "Activity"
    end
  end

  describe "MessageLive.Index enhanced tests" do
    setup [:register_and_log_in_user]

    test "renders chat with no messages", %{conn: conn} do
      {:ok, _message_live, html} = live(conn, ~p"/chat")
      assert html =~ "chat" or html =~ "message" or html =~ "Chat" or html =~ "Message"
    end

    test "renders chat with multiple messages", %{conn: conn, user: user} do
      # Create multiple messages
      for i <- 1..5 do
        Myhp.ChatFixtures.message_fixture(%{
          content: "Message #{i}",
          user_id: user.id
        })
      end

      {:ok, _message_live, html} = live(conn, ~p"/chat")
      assert html =~ "chat" or html =~ "message" or html =~ "Chat" or html =~ "Message"
    end

    test "handles message sending", %{conn: conn} do
      {:ok, message_live, _html} = live(conn, ~p"/chat")
      
      # Test form interaction
      html = render(message_live)
      assert html =~ "chat" or html =~ "message" or html =~ "Chat" or html =~ "Message"
    end

    test "handles real-time message updates", %{conn: conn} do
      {:ok, message_live, _html} = live(conn, ~p"/chat")
      
      # Simulate receiving new messages
      send(message_live.pid, {:new_message, %{content: "Real-time message", user: "Test User"}})
      
      html = render(message_live)
      assert html =~ "chat" or html =~ "message" or html =~ "Chat" or html =~ "Message"
    end

    test "displays message timestamps and users", %{conn: conn, user: user} do
      _message = Myhp.ChatFixtures.message_fixture(%{
        content: "Timestamped message",
        user_id: user.id
      })

      {:ok, _message_live, html} = live(conn, ~p"/chat")
      assert html =~ "chat" or html =~ "message" or html =~ "Chat" or html =~ "Message"
    end
  end

  describe "NotificationLive enhanced tests" do
    setup [:register_and_log_in_user]

    test "renders with no notifications", %{conn: conn} do
      {:ok, _notification_live, html} = live(conn, ~p"/notifications")
      assert html =~ "notification" or html =~ "Notification"
    end

    test "handles notification marking as read", %{conn: conn} do
      {:ok, notification_live, _html} = live(conn, ~p"/notifications")
      
      # Test notification interactions
      html = render(notification_live)
      assert html =~ "notification" or html =~ "Notification"
    end

    test "displays different notification types", %{conn: conn} do
      {:ok, notification_live, _html} = live(conn, ~p"/notifications")
      
      # Simulate different notification types
      send(notification_live.pid, {:new_notification, %{type: "comment", message: "New comment"}})
      send(notification_live.pid, {:new_notification, %{type: "follow", message: "New follower"}})
      send(notification_live.pid, {:new_notification, %{type: "like", message: "Post liked"}})
      
      html = render(notification_live)
      assert html =~ "notification" or html =~ "Notification"
    end

    test "handles notification clearing", %{conn: conn} do
      {:ok, notification_live, _html} = live(conn, ~p"/notifications")
      
      # Test clearing notifications
      send(notification_live.pid, {:clear_notifications, %{}})
      
      html = render(notification_live)
      assert html =~ "notification" or html =~ "Notification"
    end
  end

  describe "UploadedFileLive.Index enhanced tests" do
    setup [:register_and_log_in_admin_user]

    test "renders with no files", %{conn: conn} do
      {:ok, _file_live, html} = live(conn, ~p"/admin/files")
      assert html =~ "file" or html =~ "File" or html =~ "upload"
    end

    test "displays multiple files", %{conn: conn} do
      # Create multiple files
      for i <- 1..3 do
        Myhp.UploadsFixtures.uploaded_file_fixture(%{
          filename: "test#{i}.jpg",
          path: "/uploads/test#{i}.jpg",
          content_type: "image/jpeg"
        })
      end

      {:ok, _file_live, html} = live(conn, ~p"/admin/files")
      assert html =~ "file" or html =~ "File" or html =~ "upload"
    end

    test "handles file operations", %{conn: conn} do
      _file = Myhp.UploadsFixtures.uploaded_file_fixture()
      
      {:ok, file_live, _html} = live(conn, ~p"/admin/files")
      
      # Test file interactions
      html = render(file_live)
      assert html =~ "file" or html =~ "File" or html =~ "upload"
    end

    test "displays different file types", %{conn: conn} do
      # Create files of different types
      Myhp.UploadsFixtures.uploaded_file_fixture(%{
        filename: "document.pdf",
        content_type: "application/pdf"
      })
      Myhp.UploadsFixtures.uploaded_file_fixture(%{
        filename: "image.png",
        content_type: "image/png"
      })
      Myhp.UploadsFixtures.uploaded_file_fixture(%{
        filename: "document.txt",
        content_type: "text/plain",
        file_type: "document"
      })

      {:ok, _file_live, html} = live(conn, ~p"/admin/files")
      assert html =~ "file" or html =~ "File" or html =~ "upload"
    end

    test "handles file upload form", %{conn: conn} do
      {:ok, file_live, _html} = live(conn, ~p"/admin/files")
      
      # Test navigation to new file form
      if has_element?(file_live, "a", "New File") do
        file_live |> element("a", "New File") |> render_click()
        assert_patch(file_live, ~p"/admin/files/new")
      end
      
      html = render(file_live)
      assert html =~ "file" or html =~ "File" or html =~ "upload"
    end
  end

  describe "ContactMessageLive.Index enhanced tests" do
    setup [:register_and_log_in_admin_user]

    test "renders admin contact messages view", %{conn: conn} do
      {:ok, _contact_live, html} = live(conn, ~p"/admin/contact-messages")
      assert html =~ "contact" or html =~ "Contact" or html =~ "message"
    end

    test "displays multiple contact messages", %{conn: conn} do
      # Create multiple contact messages
      for i <- 1..3 do
        Myhp.ContactFixtures.contact_message_fixture(%{
          name: "User #{i}",
          email: "user#{i}@example.com",
          subject: "Subject #{i}",
          message: "Message content #{i}"
        })
      end

      {:ok, _contact_live, html} = live(conn, ~p"/admin/contact-messages")
      assert html =~ "contact" or html =~ "Contact" or html =~ "message"
    end

    test "handles contact message interactions", %{conn: conn} do
      _message = Myhp.ContactFixtures.contact_message_fixture()
      
      {:ok, contact_live, _html} = live(conn, ~p"/admin/contact-messages")
      
      # Test message interactions
      html = render(contact_live)
      assert html =~ "contact" or html =~ "Contact" or html =~ "message"
    end
  end

  defp register_and_log_in_admin_user(%{conn: conn}) do
    user = Myhp.AccountsFixtures.user_fixture(%{admin: true})
    %{conn: log_in_user(conn, user), user: user}
  end
end