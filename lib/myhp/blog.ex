defmodule Myhp.Blog do
  @moduledoc """
  The Blog context.
  """

  import Ecto.Query, warn: false
  alias Myhp.Repo

  alias Myhp.Blog.{Post, Comment}

  @doc """
  Returns the list of posts.

  ## Examples

      iex> list_posts()
      [%Post{}, ...]

  """
  def list_posts do
    Post
    |> Repo.all()
    |> Repo.preload(:tags)
  end

  @doc """
  Gets a single post.

  Raises `Ecto.NoResultsError` if the Post does not exist.

  ## Examples

      iex> get_post!(123)
      %Post{}

      iex> get_post!(456)
      ** (Ecto.NoResultsError)

  """
  def get_post!(id) do
    Post
    |> Repo.get!(id)
    |> Repo.preload(:tags)
  end

  @doc """
  Gets a single post with comments preloaded.
  """
  def get_post_with_comments!(id) do
    Post
    |> Repo.get!(id)
    |> Repo.preload(comments: [:user])
  end

  @doc """
  Returns the list of published posts.
  """
  def list_published_posts do
    Post
    |> where([p], p.published == true)
    |> order_by([p], desc: p.published_at)
    |> Repo.all()
  end

  @doc """
  Returns comments for a specific post.
  """
  def list_comments_for_post(post_id) do
    Comment
    |> where([c], c.post_id == ^post_id)
    |> order_by([c], asc: c.inserted_at)
    |> preload([:user])
    |> Repo.all()
  end

  @doc """
  Creates a post.

  ## Examples

      iex> create_post(%{field: value})
      {:ok, %Post{}}

      iex> create_post(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_post(attrs \\ %{}) do
    %Post{}
    |> Post.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a post.

  ## Examples

      iex> update_post(post, %{field: new_value})
      {:ok, %Post{}}

      iex> update_post(post, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_post(%Post{} = post, attrs) do
    post
    |> Post.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a post.

  ## Examples

      iex> delete_post(post)
      {:ok, %Post{}}

      iex> delete_post(post)
      {:error, %Ecto.Changeset{}}

  """
  def delete_post(%Post{} = post) do
    Repo.delete(post)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking post changes.

  ## Examples

      iex> change_post(post)
      %Ecto.Changeset{data: %Post{}}

  """
  def change_post(%Post{} = post, attrs \\ %{}) do
    Post.changeset(post, attrs)
  end

  alias Myhp.Blog.Comment

  @doc """
  Returns the list of comments.

  ## Examples

      iex> list_comments()
      [%Comment{}, ...]

  """
  def list_comments do
    Repo.all(Comment)
  end

  @doc """
  Gets a single comment.

  Raises `Ecto.NoResultsError` if the Comment does not exist.

  ## Examples

      iex> get_comment!(123)
      %Comment{}

      iex> get_comment!(456)
      ** (Ecto.NoResultsError)

  """
  def get_comment!(id), do: Repo.get!(Comment, id)

  @doc """
  Creates a comment.

  ## Examples

      iex> create_comment(%{field: value})
      {:ok, %Comment{}}

      iex> create_comment(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_comment(attrs \\ %{}) do
    %Comment{}
    |> Comment.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a comment.

  ## Examples

      iex> update_comment(comment, %{field: new_value})
      {:ok, %Comment{}}

      iex> update_comment(comment, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_comment(%Comment{} = comment, attrs) do
    comment
    |> Comment.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a comment.

  ## Examples

      iex> delete_comment(comment)
      {:ok, %Comment{}}

      iex> delete_comment(comment)
      {:error, %Ecto.Changeset{}}

  """
  def delete_comment(%Comment{} = comment) do
    Repo.delete(comment)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking comment changes.

  ## Examples

      iex> change_comment(comment)
      %Ecto.Changeset{data: %Comment{}}

  """
  def change_comment(%Comment{} = comment, attrs \\ %{}) do
    Comment.changeset(comment, attrs)
  end

  @doc """
  Returns the count of posts.

  ## Examples

      iex> count_posts()
      5

  """
  def count_posts do
    Repo.aggregate(Post, :count, :id)
  end

  @doc """
  Returns the count of comments.

  ## Examples

      iex> count_comments()
      10

  """
  def count_comments do
    Repo.aggregate(Comment, :count, :id)
  end

  @doc """
  Returns a query for published posts.
  """
  def list_published_posts_query do
    Post
    |> where([p], p.published == true)
    |> order_by([p], desc: p.published_at)
  end

  @doc """
  Returns a query for searching posts.
  """
  def search_posts_query(query) when is_binary(query) do
    search_term = "%#{String.downcase(query)}%"

    Post
    |> where([p], p.published == true)
    |> where(
      [p],
      like(fragment("lower(?)", p.title), ^search_term) or
        like(fragment("lower(?)", p.content), ^search_term)
    )
    |> order_by([p], desc: p.published_at)
  end

  @doc """
  Searches published posts by title and description.

  ## Examples

      iex> search_posts("elixir")
      [%Post{}, ...]

  """
  def search_posts(query) when is_binary(query) do
    search_posts_query(query)
    |> limit(20)
    |> Repo.all()
  end

  alias Myhp.Blog.Category

  @doc """
  Returns the list of categories.
  """
  def list_categories do
    Repo.all(Category)
  end

  @doc """
  Gets a single category.
  """
  def get_category!(id), do: Repo.get!(Category, id)

  @doc """
  Creates a category.
  """
  def create_category(attrs \\ %{}) do
    %Category{}
    |> Category.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a category.
  """
  def update_category(%Category{} = category, attrs) do
    category
    |> Category.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a category.
  """
  def delete_category(%Category{} = category) do
    Repo.delete(category)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking category changes.
  """
  def change_category(%Category{} = category, attrs \\ %{}) do
    Category.changeset(category, attrs)
  end

  alias Myhp.Blog.Tag

  @doc """
  Returns the list of tags.
  """
  def list_tags do
    Repo.all(Tag)
  end

  @doc """
  Gets a single tag.
  """
  def get_tag!(id), do: Repo.get!(Tag, id)

  @doc """
  Creates a tag.
  """
  def create_tag(attrs \\ %{}) do
    %Tag{}
    |> Tag.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a tag.
  """
  def update_tag(%Tag{} = tag, attrs) do
    tag
    |> Tag.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a tag.
  """
  def delete_tag(%Tag{} = tag) do
    Repo.delete(tag)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking tag changes.
  """
  def change_tag(%Tag{} = tag, attrs \\ %{}) do
    Tag.changeset(tag, attrs)
  end

  @doc """
  Returns posts filtered by category.
  """
  def list_posts_by_category(category_id) do
    Post
    |> where([p], p.category_id == ^category_id and p.published == true)
    |> order_by([p], desc: p.published_at)
    |> Repo.all()
  end

  @doc """
  Returns posts filtered by tag.
  """
  def list_posts_by_tag(tag_id) do
    Post
    |> join(:inner, [p], t in assoc(p, :tags))
    |> where([p, t], t.id == ^tag_id and p.published == true)
    |> order_by([p], desc: p.published_at)
    |> Repo.all()
  end

  @doc """
  Adds tags to a post.
  """
  def add_tags_to_post(post, tag_ids) do
    tags = Repo.all(from t in Tag, where: t.id in ^tag_ids)
    
    post
    |> Repo.preload(:tags)
    |> Ecto.Changeset.change()
    |> Ecto.Changeset.put_assoc(:tags, tags)
    |> Repo.update()
  end

  @doc """
  Returns popular tags with post counts.
  """
  def get_popular_tags(limit \\ 10) do
    Tag
    |> join(:inner, [t], p in assoc(t, :posts))
    |> where([t, p], p.published == true)
    |> group_by([t], [t.id, t.name, t.slug, t.color, t.inserted_at, t.updated_at])
    |> select([t], %{
      id: t.id,
      name: t.name,
      slug: t.slug,
      color: t.color,
      inserted_at: t.inserted_at,
      updated_at: t.updated_at,
      post_count: count(t.id)
    })
    |> order_by([t], desc: count(t.id))
    |> limit(^limit)
    |> Repo.all()
  end

  @doc """
  Returns categories with post counts.
  """
  def get_categories_with_counts do
    Category
    |> join(:left, [c], p in assoc(c, :posts))
    |> where([c, p], is_nil(p.id) or p.published == true)
    |> group_by([c], [c.id, c.name, c.slug, c.description, c.color, c.inserted_at, c.updated_at])
    |> select([c, p], %{
      id: c.id,
      name: c.name,
      slug: c.slug,
      description: c.description,
      color: c.color,
      inserted_at: c.inserted_at,
      updated_at: c.updated_at,
      post_count: count(p.id)
    })
    |> order_by([c], c.name)
    |> Repo.all()
  end
end
