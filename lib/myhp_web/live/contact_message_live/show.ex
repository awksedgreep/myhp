defmodule MyhpWeb.ContactMessageLive.Show do
  use MyhpWeb, :live_view

  alias Myhp.Contact

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    contact_message = Contact.get_contact_message!(id)

    # Mark message as read when viewed
    contact_message =
      unless contact_message.read do
        Contact.update_contact_message(contact_message, %{read: true})
        %{contact_message | read: true}
      else
        contact_message
      end

    {:noreply,
     socket
     |> assign(:page_title, "Contact Message")
     |> assign(:current_page, "admin")
     |> assign(:contact_message, contact_message)}
  end

  @impl true
  def handle_event("mark_read", _params, socket) do
    contact_message = socket.assigns.contact_message
    {:ok, updated_message} = Contact.update_contact_message(contact_message, %{read: true})

    {:noreply, assign(socket, :contact_message, updated_message)}
  end

  def handle_event("mark_unread", _params, socket) do
    contact_message = socket.assigns.contact_message
    {:ok, updated_message} = Contact.update_contact_message(contact_message, %{read: false})

    {:noreply, assign(socket, :contact_message, updated_message)}
  end

  def handle_event("delete", _params, socket) do
    Contact.delete_contact_message(socket.assigns.contact_message)

    {:noreply,
     socket
     |> put_flash(:info, "Message deleted successfully")
     |> push_navigate(to: ~p"/admin/contact-messages")}
  end

  def handle_event("copy_email", _params, socket) do
    email = socket.assigns.contact_message.email

    {:noreply,
     socket
     |> push_event("copy-email", %{email: email})
     |> put_flash(:info, "Email copied to clipboard")}
  end
end
