defmodule Myhp.Portfolio.Project do
  use Ecto.Schema
  import Ecto.Changeset

  schema "projects" do
    field :description, :string
    field :title, :string
    field :technologies, :string
    field :github_url, :string
    field :live_url, :string
    field :image_url, :string
    field :featured, :boolean, default: false
    field :published, :boolean, default: true

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(project, attrs) do
    project
    |> cast(attrs, [
      :title,
      :description,
      :technologies,
      :github_url,
      :live_url,
      :image_url,
      :featured,
      :published
    ])
    |> validate_required([:title, :description, :technologies])
    |> validate_length(:title, min: 3, max: 100)
    |> validate_length(:description, min: 10, max: 10000)
    |> validate_url(:github_url)
    |> validate_url(:live_url)
    |> validate_image_url(:image_url)
  end

  defp validate_url(changeset, field) do
    validate_change(changeset, field, fn field, value ->
      if value && String.trim(value) != "" do
        case URI.parse(value) do
          %URI{scheme: scheme} when scheme in ["http", "https"] -> []
          _ -> [{field, "must be a valid URL"}]
        end
      else
        []
      end
    end)
  end

  defp validate_image_url(changeset, field) do
    validate_change(changeset, field, fn field, value ->
      if value && String.trim(value) != "" do
        cond do
          # Allow local paths starting with /images/
          String.starts_with?(value, "/images/") -> []
          
          # Allow valid HTTP/HTTPS URLs
          match?(%URI{scheme: scheme} when scheme in ["http", "https"], URI.parse(value)) -> []
          
          # Reject invalid formats
          true -> [{field, "must be a valid URL or local image path (/images/...)"}]
        end
      else
        []
      end
    end)
  end
end
