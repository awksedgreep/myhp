defmodule MyhpWeb.ProjectLive.Index do
  use MyhpWeb, :live_view

  alias Myhp.Portfolio
  alias Myhp.Portfolio.Project

  @impl true
  def mount(_params, _session, socket) do
    current_user = socket.assigns[:current_user]
    
    projects =
      if current_user do
        Portfolio.list_projects()
      else
        Portfolio.list_published_projects()
      end

    featured_projects = Portfolio.list_featured_projects()
    other_projects = projects -- featured_projects

    {:ok,
     socket
     |> assign(:current_user, current_user)
     |> assign(:projects, projects)
     |> assign(:featured_projects, featured_projects)
     |> assign(:other_projects, other_projects)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Project")
    |> assign(:project, Portfolio.get_project!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Project")
    |> assign(:project, %Project{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Portfolio")
    |> assign(:project, nil)
  end

  @impl true
  def handle_info({MyhpWeb.ProjectLive.FormComponent, {:saved, _project}}, socket) do
    # Refresh the project lists
    projects =
      if socket.assigns[:current_user] do
        Portfolio.list_projects()
      else
        Portfolio.list_published_projects()
      end

    featured_projects = Portfolio.list_featured_projects()
    other_projects = projects -- featured_projects

    {:noreply,
     socket
     |> assign(:projects, projects)
     |> assign(:featured_projects, featured_projects)
     |> assign(:other_projects, other_projects)
     |> push_navigate(to: ~p"/portfolio")}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    project = Portfolio.get_project!(id)
    {:ok, _} = Portfolio.delete_project(project)

    # Refresh the project lists
    projects =
      if socket.assigns[:current_user] do
        Portfolio.list_projects()
      else
        Portfolio.list_published_projects()
      end

    featured_projects = Portfolio.list_featured_projects()
    other_projects = projects -- featured_projects

    {:noreply,
     socket
     |> assign(:projects, projects)
     |> assign(:featured_projects, featured_projects)
     |> assign(:other_projects, other_projects)}
  end
end
