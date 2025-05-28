defmodule Myhp.Blog.Post do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query

  schema "posts" do
    field :title, :string
    field :content, :string
    field :slug, :string
    field :published, :boolean, default: false
    field :published_at, :naive_datetime

    belongs_to :category, Myhp.Blog.Category
    has_many :comments, Myhp.Blog.Comment, preload_order: [asc: :inserted_at]
    many_to_many :tags, Myhp.Blog.Tag, join_through: "post_tags", on_replace: :delete

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(post, attrs) do
    post
    |> cast(attrs, [:title, :content, :slug, :published, :published_at, :category_id])
    |> validate_required([:title, :content])
    |> maybe_generate_slug()
    |> maybe_set_published_at()
    |> validate_required([:slug])
    |> unique_constraint(:slug)
    |> put_assoc(:tags, parse_tags(attrs))
  end

  defp maybe_generate_slug(changeset) do
    case get_change(changeset, :slug) do
      nil ->
        case get_change(changeset, :title) do
          nil -> changeset
          title -> put_change(changeset, :slug, slugify(title))
        end
      _ ->
        changeset
    end
  end

  defp maybe_set_published_at(changeset) do
    published = get_field(changeset, :published, false)
    published_at = get_field(changeset, :published_at)
    
    case {published, published_at} do
      {true, nil} ->
        put_change(changeset, :published_at, NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second))
      {false, _} ->
        put_change(changeset, :published_at, nil)
      _ ->
        changeset
    end
  end

  defp slugify(string) do
    string
    |> String.downcase()
    |> String.replace(~r/[^\w\s-]/, "")
    |> String.replace(~r/\s+/, "-")
    |> String.slice(0, 100)
  end

  defp parse_tags(%{"tag_ids" => tag_ids}) when is_list(tag_ids) do
    Myhp.Repo.all(from t in Myhp.Blog.Tag, where: t.id in ^tag_ids)
  end

  defp parse_tags(%{"tags" => tags}) when is_list(tags), do: tags

  defp parse_tags(%{"tags" => tags}) when is_binary(tags) do
    tags
    |> String.split(",")
    |> Enum.map(&String.trim/1)
    |> Enum.reject(&(&1 == ""))
    |> Enum.map(&find_or_create_tag/1)
  end

  defp parse_tags(%{tag_ids: tag_ids}) when is_list(tag_ids) do
    Myhp.Repo.all(from t in Myhp.Blog.Tag, where: t.id in ^tag_ids)
  end

  defp parse_tags(_), do: []

  defp find_or_create_tag(name) do
    case Myhp.Repo.get_by(Myhp.Blog.Tag, name: name) do
      nil ->
        {:ok, tag} =
          %Myhp.Blog.Tag{}
          |> Myhp.Blog.Tag.changeset(%{name: name})
          |> Myhp.Repo.insert()

        tag

      tag ->
        tag
    end
  end
end
