defmodule Myhp.PortfolioFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Myhp.Portfolio` context.
  """

  @doc """
  Generate a project.
  """
  def project_fixture(attrs \\ %{}) do
    {:ok, project} =
      attrs
      |> Enum.into(%{
        description: "This is a sample project description that meets the minimum length requirement.",
        featured: true,
        github_url: "https://github.com/user/project",
        image_url: "https://example.com/image.png",
        live_url: "https://example.com/project",
        published: true,
        technologies: "Elixir, Phoenix, LiveView",
        title: "Sample Project"
      })
      |> Myhp.Portfolio.create_project()

    project
  end
end
