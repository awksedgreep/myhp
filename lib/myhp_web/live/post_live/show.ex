defmodule MyhpWeb.PostLive.Show do
  use MyhpWeb, :live_view

  alias Myhp.Blog

  @impl true
  def mount(_params, _session, socket) do
    current_user = socket.assigns[:current_user]
    {:ok, assign(socket, :current_user, current_user)}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    post = Blog.get_post_with_comments!(id)

    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:post, post)}
  end

  defp page_title(:show), do: "Show Post"
  defp page_title(:edit), do: "Edit Post"

  defp markdown_to_html(markdown) do
    case Earmark.as_html(markdown) do
      {:ok, html, _} -> html
      {:error, _html, _errors} -> "<p>Error rendering markdown</p>"
    end
  end
end
