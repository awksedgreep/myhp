defmodule MyhpWeb.PostLive.Index do
  use MyhpWeb, :live_view

  alias Myhp.Blog
  alias Myhp.Blog.Post

  @impl true
  def mount(_params, _session, socket) do
    current_user = socket.assigns[:current_user]
    
    posts =
      if current_user do
        Blog.list_posts()
      else
        Blog.list_published_posts()
      end

    socket =
      socket
      |> assign(:current_user, current_user)
      |> assign(:has_posts, length(posts) > 0)
      |> stream(:posts, posts)

    {:ok, socket}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Post")
    |> assign(:post, Blog.get_post!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Post")
    |> assign(:post, %Post{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Blog Posts")
    |> assign(:post, nil)
  end

  @impl true
  def handle_info({MyhpWeb.PostLive.FormComponent, {:saved, post}}, socket) do
    socket = 
      socket
      |> assign(:has_posts, true)
      |> stream_insert(:posts, post)
      |> push_patch(to: ~p"/blog")
    
    {:noreply, socket}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    post = Blog.get_post!(id)
    {:ok, _} = Blog.delete_post(post)

    socket = stream_delete(socket, :posts, post)

    # Check if we still have posts after deletion
    current_user = socket.assigns[:current_user]
    remaining_posts =
      if current_user do
        Blog.list_posts()
      else
        Blog.list_published_posts()
      end

    socket =
      socket
      |> assign(:has_posts, length(remaining_posts) > 0)
      |> put_flash(:info, "Post deleted successfully")

    {:noreply, socket}
  end

  @doc """
  Extracts first ~500 chars of content and renders as markdown HTML.
  """
  def markdown_excerpt(content) when is_binary(content) do
    # Get first ~500 characters, trying to break at paragraph or sentence
    excerpt =
      content
      |> String.slice(0, 600)
      |> String.split("\n\n")
      |> Enum.take(3)
      |> Enum.join("\n\n")
      |> maybe_truncate(500)

    case Earmark.as_html(excerpt) do
      {:ok, html, _} -> html
      {:error, _html, _errors} -> "<p>#{excerpt}</p>"
    end
  end

  def markdown_excerpt(_), do: ""

  defp maybe_truncate(text, max_length) when byte_size(text) > max_length do
    text
    |> String.slice(0, max_length)
    |> String.replace(~r/\s+\S*$/, "")
    |> Kernel.<>("...")
  end

  defp maybe_truncate(text, _max_length), do: text
end
