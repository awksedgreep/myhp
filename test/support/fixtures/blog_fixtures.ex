defmodule Myhp.BlogFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Myhp.Blog` context.
  """

  @doc """
  Generate a unique post slug.
  """
  def unique_post_slug, do: "some slug#{System.unique_integer([:positive])}"

  @doc """
  Generate a post.
  """
  def post_fixture(attrs \\ %{}) do
    {:ok, post} =
      attrs
      |> Enum.into(%{
        content: "some content",
        published: true,
        published_at: ~N[2025-05-27 14:39:00],
        slug: unique_post_slug(),
        title: "some title"
      })
      |> Myhp.Blog.create_post()

    post
  end

  @doc """
  Generate a comment.
  """
  def comment_fixture(attrs \\ %{}) do
    # Create a user if not provided
    user = if attrs[:user_id], do: nil, else: Myhp.AccountsFixtures.user_fixture()
    
    # Create a post if not provided
    post = if attrs[:post_id], do: nil, else: post_fixture()

    {:ok, comment} =
      attrs
      |> Enum.into(%{
        content: "some content",
        user_id: user && user.id || attrs[:user_id],
        post_id: post && post.id || attrs[:post_id]
      })
      |> Myhp.Blog.create_comment()

    comment
  end
end
