defmodule MyhpWeb.UploadedFileLive.FormComponent do
  use MyhpWeb, :live_component

  alias Myhp.Uploads

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        {@title}
        <:subtitle>Edit file details and metadata</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="uploaded_file-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <div class="space-y-6">
          <!-- File Preview -->
          <div class="bg-gray-50 dark:bg-gray-700 rounded-lg p-4">
            <div class="flex items-center space-x-4">
              <div class="flex-shrink-0">
                <%= if @uploaded_file.file_type == "image" and @uploaded_file.id do %>
                  <img
                    src={Uploads.file_url(@uploaded_file)}
                    alt={@uploaded_file.alt_text || @uploaded_file.original_filename}
                    class="w-16 h-16 object-cover rounded-lg"
                  />
                <% else %>
                  <div class="w-16 h-16 bg-gray-200 dark:bg-gray-600 rounded-lg flex items-center justify-center">
                    <.icon name="hero-document" class="w-8 h-8 text-gray-400" />
                  </div>
                <% end %>
              </div>

              <div class="flex-1 min-w-0">
                <h3 class="text-sm font-medium text-gray-900 dark:text-white truncate">
                  {@uploaded_file.original_filename || "New File"}
                </h3>
                <%= if @uploaded_file.file_size do %>
                  <p class="text-sm text-gray-500 dark:text-gray-400">
                    {format_file_size(@uploaded_file.file_size)} •
                    <span class="capitalize">{@uploaded_file.file_type}</span>
                  </p>
                <% end %>
              </div>
            </div>
          </div>
          
    <!-- File Metadata -->
          <div class="grid grid-cols-1 gap-6">
            <.input
              field={@form[:description]}
              type="textarea"
              label="Description"
              placeholder="Describe this file..."
              rows="3"
            />

            <%= if @uploaded_file.file_type == "image" do %>
              <.input
                field={@form[:alt_text]}
                type="text"
                label="Alt Text"
                placeholder="Alternative text for accessibility"
              />
            <% end %>
          </div>
          
    <!-- File Information (Read-only) -->
          <%= if @uploaded_file.id do %>
            <div class="bg-gray-50 dark:bg-gray-700 rounded-lg p-4">
              <h4 class="text-sm font-medium text-gray-900 dark:text-white mb-3">File Information</h4>
              <dl class="grid grid-cols-1 sm:grid-cols-2 gap-x-4 gap-y-2 text-sm">
                <div>
                  <dt class="font-medium text-gray-500 dark:text-gray-400">Original Name</dt>
                  <dd class="text-gray-900 dark:text-white">{@uploaded_file.original_filename}</dd>
                </div>
                <div>
                  <dt class="font-medium text-gray-500 dark:text-gray-400">File Size</dt>
                  <dd class="text-gray-900 dark:text-white">
                    {format_file_size(@uploaded_file.file_size)}
                  </dd>
                </div>
                <div>
                  <dt class="font-medium text-gray-500 dark:text-gray-400">Content Type</dt>
                  <dd class="text-gray-900 dark:text-white">{@uploaded_file.content_type}</dd>
                </div>
                <div>
                  <dt class="font-medium text-gray-500 dark:text-gray-400">Uploaded</dt>
                  <dd class="text-gray-900 dark:text-white">
                    {Calendar.strftime(@uploaded_file.inserted_at, "%B %d, %Y at %I:%M %p")}
                  </dd>
                </div>
              </dl>

              <div class="mt-3 pt-3 border-t border-gray-200 dark:border-gray-600">
                <div class="flex items-center justify-between">
                  <span class="text-sm font-medium text-gray-500 dark:text-gray-400">Public URL</span>
                  <button
                    type="button"
                    phx-click="copy-url"
                    phx-target={@myself}
                    class="text-blue-600 hover:text-blue-700 dark:text-blue-400 text-sm font-medium"
                  >
                    Copy URL
                  </button>
                </div>
                <code class="text-xs text-gray-600 dark:text-gray-300 bg-gray-100 dark:bg-gray-600 px-2 py-1 rounded mt-1 block">
                  {MyhpWeb.Endpoint.url() <> Uploads.file_url(@uploaded_file)}
                </code>
              </div>
            </div>
          <% end %>
        </div>

        <:actions>
          <.button phx-disable-with="Saving..." class="w-full sm:w-auto">
            Save Changes
          </.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{uploaded_file: uploaded_file} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_new(:form, fn ->
       to_form(Uploads.change_uploaded_file(uploaded_file))
     end)}
  end

  @impl true
  def handle_event("validate", %{"uploaded_file" => uploaded_file_params}, socket) do
    changeset = Uploads.change_uploaded_file(socket.assigns.uploaded_file, uploaded_file_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"uploaded_file" => uploaded_file_params}, socket) do
    save_uploaded_file(socket, socket.assigns.action, uploaded_file_params)
  end

  def handle_event("copy-url", _params, socket) do
    url = MyhpWeb.Endpoint.url() <> Uploads.file_url(socket.assigns.uploaded_file)

    {:noreply,
     socket
     |> push_event("copy-to-clipboard", %{text: url})
     |> put_flash(:info, "URL copied to clipboard")}
  end

  defp save_uploaded_file(socket, :edit, uploaded_file_params) do
    case Uploads.update_uploaded_file(socket.assigns.uploaded_file, uploaded_file_params) do
      {:ok, uploaded_file} ->
        notify_parent({:saved, uploaded_file})

        {:noreply,
         socket
         |> put_flash(:info, "File updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_uploaded_file(socket, :new, uploaded_file_params) do
    case Uploads.create_uploaded_file(uploaded_file_params) do
      {:ok, uploaded_file} ->
        notify_parent({:saved, uploaded_file})

        {:noreply,
         socket
         |> put_flash(:info, "File created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})

  defp format_file_size(size) when size < 1024, do: "#{size} B"
  defp format_file_size(size) when size < 1024 * 1024, do: "#{Float.round(size / 1024, 1)} KB"

  defp format_file_size(size) when size < 1024 * 1024 * 1024,
    do: "#{Float.round(size / (1024 * 1024), 1)} MB"

  defp format_file_size(size), do: "#{Float.round(size / (1024 * 1024 * 1024), 1)} GB"
end
