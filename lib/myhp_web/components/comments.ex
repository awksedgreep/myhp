defmodule MyhpWeb.Components.Comments do
  use Phoenix.LiveComponent
  alias Myhp.Blog
  alias Phoenix.PubSub

  def render(assigns) do
    ~H"""
    <div class="mt-12 border-t border-gray-200 dark:border-gray-700 pt-8">
      <h3 class="text-lg font-semibold text-gray-900 dark:text-white mb-6">
        Comments ({length(@comments)})
      </h3>
      
    <!-- Comment Form (for authenticated users) -->
      <%= if @current_user do %>
        <div class="mb-8 bg-white dark:bg-gray-800 rounded-lg border border-gray-200 dark:border-gray-700 p-6">
          <.form
            for={@comment_form}
            phx-submit="create_comment"
            phx-target={@myself}
            class="space-y-4"
          >
            <div>
              <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                Add a comment
              </label>
              <textarea
                name="comment[content]"
                rows="4"
                class="w-full px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-md shadow-sm focus:ring-blue-500 focus:border-blue-500 bg-white dark:bg-gray-700 text-gray-900 dark:text-white placeholder-gray-500 dark:placeholder-gray-400"
                placeholder="Share your thoughts..."
                required
              ><%= @comment_form[:content].value %></textarea>
              <%= if @comment_form[:content].errors do %>
                <p class="mt-1 text-sm text-red-600 dark:text-red-400">
                  {Enum.map(@comment_form[:content].errors, fn {msg, _} -> msg end) |> Enum.join(", ")}
                </p>
              <% end %>
            </div>
            <div class="flex justify-end">
              <button
                type="submit"
                class="px-4 py-2 bg-blue-600 hover:bg-blue-700 text-white rounded-md font-medium transition-colors"
              >
                Post Comment
              </button>
            </div>
          </.form>
        </div>
      <% else %>
        <div class="mb-8 bg-gray-50 dark:bg-gray-800 rounded-lg border border-gray-200 dark:border-gray-700 p-6 text-center">
          <p class="text-gray-600 dark:text-gray-400 mb-4">
            Sign in to join the conversation
          </p>
          <.link
            href="/users/log_in"
            class="inline-flex items-center px-4 py-2 bg-blue-600 hover:bg-blue-700 text-white rounded-md font-medium transition-colors"
          >
            Sign In
          </.link>
        </div>
      <% end %>
      
    <!-- Comments List -->
      <div class="space-y-6">
        <%= for comment <- @comments do %>
          <div class="bg-white dark:bg-gray-800 rounded-lg border border-gray-200 dark:border-gray-700 p-6">
            <div class="flex items-start space-x-4">
              <!-- Avatar -->
              <div class="flex-shrink-0">
                <div class="w-8 h-8 bg-gray-300 dark:bg-gray-600 rounded-full flex items-center justify-center">
                  <span class="text-sm font-medium text-gray-700 dark:text-gray-300">
                    {String.at(comment.user.email, 0) |> String.upcase()}
                  </span>
                </div>
              </div>
              
    <!-- Comment Content -->
              <div class="flex-1 min-w-0">
                <div class="flex items-center space-x-2 mb-2">
                  <span class="text-sm font-medium text-gray-900 dark:text-white">
                    {comment.user.email}
                  </span>
                  <span class="text-sm text-gray-500 dark:text-gray-400">
                    {format_comment_date(comment.inserted_at)}
                  </span>
                </div>

                <div class="text-gray-700 dark:text-gray-300 whitespace-pre-wrap">
                  {comment.content}
                </div>

                <%= if @current_user && @current_user.id == comment.user_id do %>
                  <div class="mt-3 flex space-x-2">
                    <button
                      phx-click="delete_comment"
                      phx-value-id={comment.id}
                      phx-target={@myself}
                      data-confirm="Are you sure you want to delete this comment?"
                      class="text-sm text-red-600 hover:text-red-700 dark:text-red-400 dark:hover:text-red-300"
                    >
                      Delete
                    </button>
                  </div>
                <% end %>
              </div>
            </div>
          </div>
        <% end %>

        <%= if Enum.empty?(@comments) do %>
          <div class="text-center py-8">
            <svg
              class="mx-auto h-12 w-12 text-gray-400 dark:text-gray-500"
              fill="none"
              viewBox="0 0 24 24"
              stroke="currentColor"
            >
              <path
                stroke-linecap="round"
                stroke-linejoin="round"
                stroke-width="2"
                d="M8 12h.01M12 12h.01M16 12h.01M21 12c0 4.418-4.03 8-9 8a9.863 9.863 0 01-4.255-.949L3 20l1.395-3.72C3.512 15.042 3 13.574 3 12c0-4.418 4.03-8 9-8s9 3.582 9 8z"
              />
            </svg>
            <h3 class="mt-2 text-sm font-medium text-gray-900 dark:text-white">No comments yet</h3>
            <p class="mt-1 text-sm text-gray-500 dark:text-gray-400">
              Be the first to share your thoughts!
            </p>
          </div>
        <% end %>
      </div>
    </div>
    """
  end

  def mount(socket) do
    {:ok, assign(socket, comment_form: to_form(Blog.change_comment(%Blog.Comment{})))}
  end

  def update(%{post: post, current_user: _current_user} = assigns, socket) do
    comments = Blog.list_comments_for_post(post.id)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:comments, comments)
     |> assign(:comment_form, to_form(Blog.change_comment(%Blog.Comment{})))}
  end

  def handle_event("create_comment", %{"comment" => comment_params}, socket) do
    %{post: post, current_user: current_user} = socket.assigns

    comment_params =
      comment_params
      |> Map.put("user_id", current_user.id)
      |> Map.put("post_id", post.id)

    case Blog.create_comment(comment_params) do
      {:ok, comment} ->
        # Broadcast new comment notification
        comment_with_user = Blog.get_comment!(comment.id) |> Myhp.Repo.preload([:user, :post])
        PubSub.broadcast(Myhp.PubSub, "notifications:all", {:new_comment, comment_with_user})

        comments = Blog.list_comments_for_post(post.id)

        {:noreply,
         socket
         |> assign(:comments, comments)
         |> assign(:comment_form, to_form(Blog.change_comment(%Blog.Comment{})))
         |> put_flash(:info, "Comment posted successfully!")}

      {:error, changeset} ->
        {:noreply, assign(socket, comment_form: to_form(changeset))}
    end
  end

  def handle_event("delete_comment", %{"id" => id}, socket) do
    comment = Blog.get_comment!(id)

    case Blog.delete_comment(comment) do
      {:ok, _comment} ->
        comments = Blog.list_comments_for_post(socket.assigns.post.id)

        {:noreply,
         socket
         |> assign(:comments, comments)
         |> put_flash(:info, "Comment deleted successfully!")}

      {:error, _changeset} ->
        {:noreply, put_flash(socket, :error, "Unable to delete comment")}
    end
  end

  defp format_comment_date(datetime) do
    now = DateTime.utc_now()
    comment_time = DateTime.from_naive!(datetime, "Etc/UTC")
    diff = DateTime.diff(now, comment_time, :second)

    cond do
      diff < 60 -> "just now"
      diff < 3600 -> "#{div(diff, 60)} minutes ago"
      diff < 86400 -> "#{div(diff, 3600)} hours ago"
      diff < 604_800 -> "#{div(diff, 86400)} days ago"
      true -> Calendar.strftime(comment_time, "%B %d, %Y")
    end
  end
end
