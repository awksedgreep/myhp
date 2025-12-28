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
end
