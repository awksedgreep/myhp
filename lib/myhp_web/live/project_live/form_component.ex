defmodule MyhpWeb.ProjectLive.FormComponent do
  use MyhpWeb, :live_component

  alias Myhp.Portfolio

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        {@title}
        <:subtitle>Create and manage your portfolio projects.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id={"project-form-#{@id}"}
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
        class="space-y-6"
      >
        <div class="grid grid-cols-1 gap-6">
          <.input
            field={@form[:title]}
            type="text"
            label="Project Title"
            placeholder="My Awesome Project"
            required
          />

          <.input
            field={@form[:description]}
            type="textarea"
            label="Description"
            placeholder="Describe what this project does, the problems it solves, and your role in building it..."
            rows="4"
            required
          />

          <.input
            field={@form[:technologies]}
            type="text"
            label="Technologies"
            placeholder="React, Node.js, PostgreSQL, Docker (comma-separated)"
            required
          />
        </div>

        <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
          <.input
            field={@form[:github_url]}
            type="url"
            label="GitHub URL"
            placeholder="https://github.com/username/project"
          />

          <.input
            field={@form[:live_url]}
            type="url"
            label="Live Demo URL"
            placeholder="https://project-demo.com"
          />
        </div>

        <div class="space-y-4">
          <label class="block text-sm font-medium text-gray-700 dark:text-gray-300">
            Project Image
          </label>
          
          <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div>
              <label class="block text-xs text-gray-500 dark:text-gray-400 mb-2">
                Choose Local Image
              </label>
              <.input
                field={@form[:local_image]}
                type="select"
                options={@local_image_options}
                prompt="Select a local image..."
                phx-target={@myself}
              />
            </div>
            
            <div>
              <label class="block text-xs text-gray-500 dark:text-gray-400 mb-2">
                Or Enter Custom URL
              </label>
              <.input
                field={@form[:image_url]}
                type="text"
                placeholder="https://example.com/project-screenshot.png"
                phx-target={@myself}
              />
            </div>
          </div>
          
          <%= if @image_preview do %>
            <div class="mt-4">
              <label class="block text-xs text-gray-500 dark:text-gray-400 mb-2">
                Preview
              </label>
              <div class="w-32 h-32 border border-gray-300 dark:border-gray-600 rounded-lg overflow-hidden">
                <img 
                  src={@image_preview} 
                  alt="Preview" 
                  class="w-full h-full object-cover"
                />
              </div>
            </div>
          <% end %>
        </div>

        <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
          <.input field={@form[:featured]} type="checkbox" label="Featured Project" />
          <.input field={@form[:published]} type="checkbox" label="Published" />
        </div>

        <:actions>
          <.button phx-disable-with="Saving..." class="w-full md:w-auto">Save Project</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{project: project} = assigns, socket) do
    local_image_options = get_local_image_options()
    
    {:ok,
     socket
     |> assign(assigns)
     |> assign(:local_image_options, local_image_options)
     |> assign(:image_preview, get_current_image_preview(project))
     |> assign_new(:form, fn ->
       to_form(Portfolio.change_project(project))
     end)}
  end

  @impl true
  def handle_event("validate", %{"project" => project_params}, socket) do
    # Handle local image selection
    project_params = handle_image_selection(project_params)
    
    changeset = Portfolio.change_project(socket.assigns.project, project_params)
    image_preview = get_image_preview_from_params(project_params)
    
    {:noreply, 
     socket
     |> assign(form: to_form(changeset, action: :validate))
     |> assign(:image_preview, image_preview)}
  end

  def handle_event("save", %{"project" => project_params}, socket) do
    # Handle local image selection before saving
    project_params = handle_image_selection(project_params)
    save_project(socket, socket.assigns.action, project_params)
  end

  defp save_project(socket, :edit, project_params) do
    case Portfolio.update_project(socket.assigns.project, project_params) do
      {:ok, project} ->
        notify_parent({:saved, project})

        {:noreply,
         socket
         |> put_flash(:info, "Project updated successfully")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_project(socket, :new, project_params) do
    case Portfolio.create_project(project_params) do
      {:ok, project} ->
        notify_parent({:saved, project})

        {:noreply,
         socket
         |> put_flash(:info, "Project created successfully")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})

  defp get_local_image_options do
    images_path = Path.join([Application.app_dir(:myhp), "priv", "static", "images"])
    
    case File.ls(images_path) do
      {:ok, files} ->
        files
        |> Enum.filter(&is_image_file?/1)
        |> Enum.map(fn file -> 
          {file, "/images/#{file}"}
        end)
        |> Enum.sort()
      
      {:error, _} -> []
    end
  end

  defp is_image_file?(filename) do
    ext = Path.extname(filename) |> String.downcase()
    ext in [".jpg", ".jpeg", ".png", ".gif", ".webp", ".svg"]
  end

  defp handle_image_selection(%{"local_image" => local_image} = params) when local_image != "" do
    # If a local image is selected, use it and clear the custom URL
    params
    |> Map.put("image_url", local_image)
    |> Map.delete("local_image")
  end

  defp handle_image_selection(params) do
    # Remove the local_image field if it's empty or not present
    Map.delete(params, "local_image")
  end

  defp get_current_image_preview(%{image_url: image_url}) when not is_nil(image_url) and image_url != "" do
    image_url
  end

  defp get_current_image_preview(_), do: nil

  defp get_image_preview_from_params(%{"image_url" => image_url}) when not is_nil(image_url) and image_url != "" do
    image_url
  end

  defp get_image_preview_from_params(%{"local_image" => local_image}) when not is_nil(local_image) and local_image != "" do
    local_image
  end

  defp get_image_preview_from_params(_), do: nil
end
