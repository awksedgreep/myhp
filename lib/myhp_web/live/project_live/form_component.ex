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
        id="project-form"
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

        <.input
          field={@form[:image_url]}
          type="url"
          label="Project Image URL"
          placeholder="https://example.com/project-screenshot.png"
        />

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
    {:ok,
     socket
     |> assign(assigns)
     |> assign_new(:form, fn ->
       to_form(Portfolio.change_project(project))
     end)}
  end

  @impl true
  def handle_event("validate", %{"project" => project_params}, socket) do
    changeset = Portfolio.change_project(socket.assigns.project, project_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"project" => project_params}, socket) do
    save_project(socket, socket.assigns.action, project_params)
  end

  defp save_project(socket, :edit, project_params) do
    case Portfolio.update_project(socket.assigns.project, project_params) do
      {:ok, project} ->
        notify_parent({:saved, project})

        {:noreply,
         socket
         |> put_flash(:info, "Project updated successfully")
         |> push_patch(to: socket.assigns.patch)}

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
         |> put_flash(:info, "Project created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
