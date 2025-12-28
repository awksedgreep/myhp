defmodule MyhpWeb.PostLive.FormComponent do
  use MyhpWeb, :live_component

  alias Myhp.Blog

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        {@title}
        <:subtitle>Create and manage your blog posts.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id={"post-form-#{@id}"}
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:title]} type="text" label="Title" required />
        
    <!-- Enhanced Content Editor -->
        <div class="space-y-4">
          <label class="block text-sm font-medium text-gray-700 dark:text-gray-300">
            Content <span class="text-red-500">*</span>
          </label>
          <div class="grid grid-cols-1 lg:grid-cols-2 gap-4">
            <!-- Editor Tab -->
            <div>
              <div class="bg-gray-50 dark:bg-gray-800 px-3 py-2 border-b border-gray-200 dark:border-gray-600 rounded-t-lg">
                <span class="text-sm font-medium text-gray-700 dark:text-gray-300">
                  Markdown Editor
                </span>
              </div>
              <textarea
                id={@form[:content].id}
                name={@form[:content].name}
                class="block w-full min-h-96 px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-b-lg bg-white dark:bg-gray-900 text-gray-900 dark:text-white placeholder-gray-500 dark:placeholder-gray-400 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500 font-mono text-sm"
                placeholder="Write your post content in Markdown..."
                phx-debounce="300"
              ><%= @form[:content].value %></textarea>
              <div class="text-xs text-gray-500 dark:text-gray-400 mt-1">
                Supports Markdown formatting: **bold**, *italic*, `code`, etc.
              </div>
              <%= if @form[:content].errors != [] do %>
                <div class="mt-1 text-sm text-red-600">
                  <%= for {msg, _opts} <- @form[:content].errors do %>
                    <div>{msg}</div>
                  <% end %>
                </div>
              <% end %>
            </div>
            
    <!-- Preview Tab -->
            <div class="hidden lg:block">
              <div class="bg-gray-50 dark:bg-gray-800 px-3 py-2 border-b border-gray-200 dark:border-gray-600 rounded-t-lg">
                <span class="text-sm font-medium text-gray-700 dark:text-gray-300">Preview</span>
              </div>
              <div class="min-h-96 p-3 border border-gray-300 dark:border-gray-600 rounded-b-lg bg-white dark:bg-gray-900">
                <div class="prose prose-sm dark:prose-invert max-w-none">
                  <%= if @form[:content].value && @form[:content].value != "" do %>
                    {raw(markdown_to_html(@form[:content].value))}
                  <% else %>
                    <p class="text-gray-500 dark:text-gray-400 italic">
                      Preview will appear here as you type...
                    </p>
                  <% end %>
                </div>
              </div>
            </div>
          </div>
        </div>

        <.input field={@form[:slug]} type="text" label="URL Slug" placeholder="my-blog-post" />
        <.input field={@form[:published]} type="checkbox" label="Published" />
        <.input field={@form[:published_at]} type="datetime-local" label="Published at" />
        <:actions>
          <.button phx-disable-with="Saving...">Save Post</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{post: post} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_new(:form, fn ->
       to_form(Blog.change_post(post))
     end)}
  end

  defp markdown_to_html(markdown) do
    case Earmark.as_html(markdown) do
      {:ok, html, _} -> html
      {:error, _html, _errors} -> "<p>Error rendering markdown</p>"
    end
  end

  @impl true
  def handle_event("validate", %{"post" => post_params}, socket) do
    changeset = Blog.change_post(socket.assigns.post, post_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"post" => post_params}, socket) do
    save_post(socket, socket.assigns.action, post_params)
  end

  defp save_post(socket, :edit, post_params) do
    case Blog.update_post(socket.assigns.post, post_params) do
      {:ok, post} ->
        notify_parent({:saved, post})

        {:noreply,
         socket
         |> put_flash(:info, "Post updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_post(socket, :new, post_params) do
    # Auto-generate slug if not provided
    post_params = maybe_generate_slug(post_params)

    case Blog.create_post(post_params) do
      {:ok, post} ->
        notify_parent({:saved, post})

        {:noreply,
         socket
         |> put_flash(:info, "Post created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})

  defp maybe_generate_slug(%{"title" => title, "slug" => slug} = params) when slug in ["", nil] do
    generated_slug =
      title
      |> String.downcase()
      |> String.replace(~r/[^a-z0-9\s-]/, "")
      |> String.replace(~r/\s+/, "-")
      |> String.trim("-")

    Map.put(params, "slug", generated_slug)
  end

  defp maybe_generate_slug(params), do: params
end
