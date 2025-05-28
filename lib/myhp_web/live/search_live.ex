defmodule MyhpWeb.SearchLive do
  use MyhpWeb, :live_view

  alias Myhp.Blog
  alias Myhp.Portfolio

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:query, "")
     |> assign(:results, %{posts: [], projects: []})
     |> assign(:searching, false)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    query = params["q"] || ""

    socket =
      socket
      |> assign(:query, query)
      |> assign(:page_title, if(query == "", do: "Search", else: "Search: #{query}"))

    if query != "" and String.length(query) >= 2 do
      {:noreply, perform_search(socket, query)}
    else
      {:noreply, assign(socket, :results, %{posts: [], projects: []})}
    end
  end

  @impl true
  def handle_event("search", %{"query" => query}, socket) do
    query = String.trim(query)

    socket = assign(socket, :query, query)

    if String.length(query) >= 2 do
      {:noreply,
       socket
       |> assign(:searching, true)
       |> push_patch(to: ~p"/search?#{%{q: query}}")}
    else
      {:noreply,
       socket
       |> assign(:results, %{posts: [], projects: []})
       |> assign(:searching, false)}
    end
  end

  defp perform_search(socket, query) do
    posts = Blog.search_posts(query)
    projects = Portfolio.search_projects(query)

    socket
    |> assign(:results, %{posts: posts, projects: projects})
    |> assign(:searching, false)
  end
end
