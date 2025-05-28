defmodule Myhp.Portfolio do
  @moduledoc """
  The Portfolio context.
  """

  import Ecto.Query, warn: false
  alias Myhp.Repo

  alias Myhp.Portfolio.Project

  @doc """
  Returns the list of projects.

  ## Examples

      iex> list_projects()
      [%Project{}, ...]

  """
  def list_projects do
    Repo.all(Project)
  end

  @doc """
  Returns the list of published projects.
  """
  def list_published_projects do
    Project
    |> where([p], p.published == true)
    |> order_by([p], desc: p.featured, desc: p.inserted_at)
    |> Repo.all()
  end

  @doc """
  Returns featured projects only.
  """
  def list_featured_projects do
    Project
    |> where([p], p.published == true and p.featured == true)
    |> order_by([p], desc: p.inserted_at)
    |> Repo.all()
  end

  @doc """
  Gets a single project.

  Raises `Ecto.NoResultsError` if the Project does not exist.

  ## Examples

      iex> get_project!(123)
      %Project{}

      iex> get_project!(456)
      ** (Ecto.NoResultsError)

  """
  def get_project!(id), do: Repo.get!(Project, id)

  @doc """
  Creates a project.

  ## Examples

      iex> create_project(%{field: value})
      {:ok, %Project{}}

      iex> create_project(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_project(attrs \\ %{}) do
    %Project{}
    |> Project.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a project.

  ## Examples

      iex> update_project(project, %{field: new_value})
      {:ok, %Project{}}

      iex> update_project(project, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_project(%Project{} = project, attrs) do
    project
    |> Project.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a project.

  ## Examples

      iex> delete_project(project)
      {:ok, %Project{}}

      iex> delete_project(project)
      {:error, %Ecto.Changeset{}}

  """
  def delete_project(%Project{} = project) do
    Repo.delete(project)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking project changes.

  ## Examples

      iex> change_project(project)
      %Ecto.Changeset{data: %Project{}}

  """
  def change_project(%Project{} = project, attrs \\ %{}) do
    Project.changeset(project, attrs)
  end

  @doc """
  Returns the count of projects.

  ## Examples

      iex> count_projects()
      6

  """
  def count_projects do
    Repo.aggregate(Project, :count, :id)
  end

  @doc """
  Returns a query for searching projects.
  """
  def search_projects_query(query) when is_binary(query) do
    search_term = "%#{String.downcase(query)}%"

    Project
    |> where([p], p.published == true)
    |> where(
      [p],
      like(fragment("lower(?)", p.title), ^search_term) or
        like(fragment("lower(?)", p.description), ^search_term)
    )
    |> order_by([p], desc: p.featured, desc: p.inserted_at)
  end

  @doc """
  Searches published projects by title, description, and technologies.

  ## Examples

      iex> search_projects("elixir")
      [%Project{}, ...]

  """
  def search_projects(query) when is_binary(query) do
    search_projects_query(query)
    |> limit(20)
    |> Repo.all()
  end
end
