defmodule MyhpWeb.ContactMessageLiveTest do
  use MyhpWeb.ConnCase

  import Phoenix.LiveViewTest
  import Myhp.ContactFixtures

  describe "Index (Contact Form)" do
    test "renders contact form", %{conn: conn} do
      {:ok, _index_live, html} = live(conn, ~p"/contact")

      assert html =~ "Get In Touch"
      assert html =~ "Send Message"
    end

    test "can submit contact form", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/contact")

      valid_attrs = %{
        name: "John Doe",
        email: "john@example.com",
        subject: "Test Subject",
        message: "Test message"
      }

      assert index_live
             |> form("#contact-form", contact_message: valid_attrs)
             |> render_submit()

      # Should redirect or show success message
    end
  end

  describe "Index (Admin)" do
    setup [:register_and_log_in_admin_user]

    test "lists contact messages for admin", %{conn: conn} do
      _message = contact_message_fixture(%{name: "Test User", subject: "Test Subject"})

      {:ok, _index_live, html} = live(conn, ~p"/admin/contact-messages")

      assert html =~ "Contact Messages"
      assert html =~ "Test User"
      assert html =~ "Test Subject"
    end
  end

  describe "Show (Admin)" do
    setup [:register_and_log_in_admin_user, :create_contact_message]

    test "displays contact message", %{conn: conn, contact_message: message} do
      {:ok, _show_live, html} = live(conn, ~p"/admin/contact-messages/#{message}")

      assert html =~ message.name
      assert html =~ message.subject
      assert html =~ message.message
    end

    defp create_contact_message(_) do
      message = contact_message_fixture()
      %{contact_message: message}
    end
  end

  defp register_and_log_in_admin_user(%{conn: conn}) do
    user = Myhp.AccountsFixtures.user_fixture(%{admin: true})
    %{conn: log_in_user(conn, user), user: user}
  end
end