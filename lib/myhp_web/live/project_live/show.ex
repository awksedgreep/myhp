defmodule MyhpWeb.ProjectLive.Show do
  use MyhpWeb, :live_view

  alias Myhp.Portfolio

  @impl true
  def mount(_params, _session, socket) do
    current_user = socket.assigns[:current_user]
    {:ok, assign(socket, :current_user, current_user)}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:project, Portfolio.get_project!(id))}
  end

  defp page_title(:show), do: "Show Project"
  defp page_title(:edit), do: "Edit Project"
end
