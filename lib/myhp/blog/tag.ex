defmodule Myhp.Blog.Tag do
  use Ecto.Schema
  import Ecto.Changeset

  schema "tags" do
    field :name, :string
    field :slug, :string
    field :color, :string, default: "#10B981"

    many_to_many :posts, Myhp.Blog.Post, join_through: "post_tags"

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(tag, attrs) do
    tag
    |> cast(attrs, [:name, :slug, :color])
    |> validate_required([:name])
    |> validate_length(:name, min: 2, max: 50)
    |> normalize_name()
    |> unique_constraint(:name)
    |> unique_constraint(:slug)
    |> maybe_generate_slug()
    |> validate_required([:slug])
  end

  defp normalize_name(changeset) do
    case get_change(changeset, :name) do
      nil -> changeset
      name ->
        normalized = name |> String.trim() |> String.downcase()
        put_change(changeset, :name, normalized)
    end
  end

  defp maybe_generate_slug(changeset) do
    case get_change(changeset, :slug) do
      nil ->
        case get_change(changeset, :name) do
          nil -> changeset
          name -> put_change(changeset, :slug, slugify(name))
        end

      _ ->
        changeset
    end
  end

  defp slugify(string) do
    string
    |> String.downcase()
    |> String.replace(~r/[^\w\s-]/, "")
    |> String.replace(~r/\s+/, "-")
  end
end
