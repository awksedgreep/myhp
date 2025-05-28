defmodule MyhpWeb.ContactMessageLive.Index do
  use MyhpWeb, :live_view

  alias Myhp.Contact
  alias Myhp.Contact.ContactMessage

  @impl true
  def mount(_params, _session, socket) do
    if socket.assigns.live_action == :new do
      # Public contact form
      {:ok,
       socket
       |> assign(:page_title, "Contact")
       |> assign(:contact_message, %ContactMessage{})
       |> assign(:form, to_form(Contact.change_contact_message(%ContactMessage{})))}
    else
      # Admin messages list (requires authentication)
      messages = Contact.list_contact_messages()

      {:ok,
       socket
       |> assign(:page_title, "Contact Messages")
       |> assign(:messages, messages)}
    end
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Contact message")
    |> assign(:contact_message, Contact.get_contact_message!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "Contact")
  end

  defp apply_action(socket, :index, _params) do
    messages = Contact.list_contact_messages()

    socket
    |> assign(:page_title, "Contact Messages")
    |> assign(:current_page, "admin")
    |> assign(:messages, messages)
    |> assign(:contact_message, nil)
  end

  @impl true
  def handle_event("validate", %{"contact_message" => contact_message_params}, socket) do
    changeset =
      Contact.change_contact_message(socket.assigns.contact_message, contact_message_params)

    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"contact_message" => contact_message_params}, socket) do
    case Contact.create_contact_message(contact_message_params) do
      {:ok, _contact_message} ->
        {:noreply,
         socket
         |> put_flash(:info, "Thank you for your message! I'll get back to you soon.")
         |> assign(:form, to_form(Contact.change_contact_message(%ContactMessage{})))
         |> assign(:contact_message, %ContactMessage{})}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    contact_message = Contact.get_contact_message!(id)
    {:ok, _} = Contact.delete_contact_message(contact_message)

    messages = Contact.list_contact_messages()
    {:noreply, assign(socket, :messages, messages)}
  end

  @impl true
  def handle_info({MyhpWeb.ContactMessageLive.FormComponent, {:saved, _contact_message}}, socket) do
    messages = Contact.list_contact_messages()
    {:noreply, assign(socket, :messages, messages)}
  end
end
