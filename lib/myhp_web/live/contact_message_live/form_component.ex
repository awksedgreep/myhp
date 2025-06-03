defmodule MyhpWeb.ContactMessageLive.FormComponent do
  use MyhpWeb, :live_component

  alias Myhp.Contact

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        {@title}
        <:subtitle>Use this form to manage contact_message records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id={"contact_message-form-#{@id}"}
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:name]} type="text" label="Name" />
        <.input field={@form[:email]} type="text" label="Email" />
        <.input field={@form[:subject]} type="text" label="Subject" />
        <.input field={@form[:message]} type="text" label="Message" />
        <.input field={@form[:read]} type="checkbox" label="Read" />
        <:actions>
          <.button phx-disable-with="Saving...">Save Contact message</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{contact_message: contact_message} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_new(:form, fn ->
       to_form(Contact.change_contact_message(contact_message))
     end)}
  end

  @impl true
  def handle_event("validate", %{"contact_message" => contact_message_params}, socket) do
    changeset =
      Contact.change_contact_message(socket.assigns.contact_message, contact_message_params)

    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"contact_message" => contact_message_params}, socket) do
    save_contact_message(socket, socket.assigns.action, contact_message_params)
  end

  defp save_contact_message(socket, :edit, contact_message_params) do
    case Contact.update_contact_message(socket.assigns.contact_message, contact_message_params) do
      {:ok, contact_message} ->
        notify_parent({:saved, contact_message})

        {:noreply,
         socket
         |> put_flash(:info, "Contact message updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_contact_message(socket, :new, contact_message_params) do
    case Contact.create_contact_message(contact_message_params) do
      {:ok, contact_message} ->
        notify_parent({:saved, contact_message})

        {:noreply,
         socket
         |> put_flash(:info, "Contact message created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
