defmodule MyhpWeb.ApiController do
  use MyhpWeb, :controller
  
  import Ecto.Query

  alias Myhp.{Blog, Accounts, Portfolio, Repo}
  alias Myhp.Blog.Post
  alias Myhp.Accounts.User

  def blog(conn, params) do
    page = Map.get(params, "page", "1") |> String.to_integer()
    per_page = Map.get(params, "per_page", "10") |> String.to_integer()

    query =
      case Map.get(params, "search") do
        nil -> Blog.list_published_posts_query()
        search_term -> Blog.search_posts_query(search_term)
      end

    posts =
      query
      |> Repo.paginate(page: page, page_size: per_page)

    json(conn, %{
      data: Enum.map(posts.entries, &serialize_post/1),
      pagination: %{
        current_page: posts.page_number,
        per_page: posts.page_size,
        total_pages: posts.total_pages,
        total_entries: posts.total_entries
      }
    })
  end

  def users(conn, params) do
    page = Map.get(params, "page", "1") |> String.to_integer()
    per_page = Map.get(params, "per_page", "10") |> String.to_integer()

    query =
      case Map.get(params, "search") do
        nil -> Accounts.list_users_query()
        search_term -> Accounts.search_users_query(search_term)
      end

    users =
      query
      |> Repo.paginate(page: page, page_size: per_page)

    json(conn, %{
      data: Enum.map(users.entries, &serialize_user/1),
      pagination: %{
        current_page: users.page_number,
        per_page: users.page_size,
        total_pages: users.total_pages,
        total_entries: users.total_entries
      }
    })
  end

  def search(conn, %{"q" => query} = params) do
    page = Map.get(params, "page", "1") |> String.to_integer()
    per_page = Map.get(params, "per_page", "10") |> String.to_integer()

    # Combine posts and projects for unified search
    posts_query = Blog.search_posts_query(query)
    projects_query = Portfolio.search_projects_query(query)
    
    # Get paginated posts
    posts_result = posts_query |> Repo.paginate(page: page, page_size: per_page)
    
    # For projects, just get a limited set since we're combining results
    projects = projects_query |> limit(5) |> Repo.all()

    combined_results = Enum.map(posts_result.entries, &serialize_post/1) ++
                      Enum.map(projects, &serialize_project/1)

    json(conn, %{
      data: combined_results,
      pagination: %{
        current_page: posts_result.page_number,
        per_page: posts_result.page_size,
        total_pages: posts_result.total_pages,
        total_entries: posts_result.total_entries + length(projects)
      },
      query: query
    })
  end

  def search(conn, _params) do
    conn
    |> put_status(:bad_request)
    |> json(%{error: "Query parameter 'q' is required"})
  end

  defp serialize_post(%Post{} = post) do
    %{
      id: post.id,
      title: post.title,
      content: post.content,
      slug: post.slug,
      published: post.published,
      published_at: post.published_at,
      inserted_at: post.inserted_at,
      updated_at: post.updated_at
    }
  end

  defp serialize_user(%User{} = user) do
    %{
      id: user.id,
      email: user.email,
      admin: user.admin,
      confirmed_at: user.confirmed_at,
      inserted_at: user.inserted_at,
      updated_at: user.updated_at
    }
  end

  defp serialize_project(project) do
    %{
      id: project.id,
      title: project.title,
      description: project.description,
      technologies: project.technologies,
      github_url: project.github_url,
      live_url: project.live_url,
      featured: project.featured,
      inserted_at: project.inserted_at,
      updated_at: project.updated_at
    }
  end
end
