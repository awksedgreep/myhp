defmodule Myhp.BlogTest do
  use Myhp.DataCase

  alias Myhp.Blog

  describe "posts" do
    alias Myhp.Blog.Post

    import Myhp.BlogFixtures

    @invalid_attrs %{title: nil, content: nil, slug: nil, published: nil, published_at: nil}

    test "list_posts/0 returns all posts" do
      post = post_fixture()
      assert Blog.list_posts() == [post]
    end

    test "get_post!/1 returns the post with given id" do
      post = post_fixture()
      assert Blog.get_post!(post.id) == post
    end

    test "create_post/1 with valid data creates a post" do
      valid_attrs = %{
        title: "some title",
        content: "some content",
        slug: "some slug",
        published: true,
        published_at: ~N[2025-05-27 14:39:00]
      }

      assert {:ok, %Post{} = post} = Blog.create_post(valid_attrs)
      assert post.title == "some title"
      assert post.content == "some content"
      assert post.slug == "some slug"
      assert post.published == true
      assert post.published_at == ~N[2025-05-27 14:39:00]
    end

    test "create_post/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Blog.create_post(@invalid_attrs)
    end

    test "update_post/2 with valid data updates the post" do
      post = post_fixture()

      update_attrs = %{
        title: "some updated title",
        content: "some updated content",
        slug: "some updated slug",
        published: false
      }

      assert {:ok, %Post{} = post} = Blog.update_post(post, update_attrs)
      assert post.title == "some updated title"
      assert post.content == "some updated content"
      assert post.slug == "some updated slug"
      assert post.published == false
      assert post.published_at == nil
    end

    test "update_post/2 with invalid data returns error changeset" do
      post = post_fixture()
      assert {:error, %Ecto.Changeset{}} = Blog.update_post(post, @invalid_attrs)
      assert post == Blog.get_post!(post.id)
    end

    test "delete_post/1 deletes the post" do
      post = post_fixture()
      assert {:ok, %Post{}} = Blog.delete_post(post)
      assert_raise Ecto.NoResultsError, fn -> Blog.get_post!(post.id) end
    end

    test "change_post/1 returns a post changeset" do
      post = post_fixture()
      assert %Ecto.Changeset{} = Blog.change_post(post)
    end
  end

  describe "comments" do
    alias Myhp.Blog.Comment

    import Myhp.BlogFixtures

    @invalid_attrs %{content: nil}

    test "list_comments/0 returns all comments" do
      comment = comment_fixture()
      assert Blog.list_comments() == [comment]
    end

    test "get_comment!/1 returns the comment with given id" do
      comment = comment_fixture()
      assert Blog.get_comment!(comment.id) == comment
    end

    test "create_comment/1 with valid data creates a comment" do
      user = Myhp.AccountsFixtures.user_fixture()
      post = post_fixture()
      valid_attrs = %{content: "some content", user_id: user.id, post_id: post.id}

      assert {:ok, %Comment{} = comment} = Blog.create_comment(valid_attrs)
      assert comment.content == "some content"
      assert comment.user_id == user.id
      assert comment.post_id == post.id
    end

    test "create_comment/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Blog.create_comment(@invalid_attrs)
    end

    test "update_comment/2 with valid data updates the comment" do
      comment = comment_fixture()
      update_attrs = %{content: "some updated content"}

      assert {:ok, %Comment{} = comment} = Blog.update_comment(comment, update_attrs)
      assert comment.content == "some updated content"
    end

    test "update_comment/2 with invalid data returns error changeset" do
      comment = comment_fixture()
      assert {:error, %Ecto.Changeset{}} = Blog.update_comment(comment, @invalid_attrs)
      assert comment == Blog.get_comment!(comment.id)
    end

    test "delete_comment/1 deletes the comment" do
      comment = comment_fixture()
      assert {:ok, %Comment{}} = Blog.delete_comment(comment)
      assert_raise Ecto.NoResultsError, fn -> Blog.get_comment!(comment.id) end
    end

    test "change_comment/1 returns a comment changeset" do
      comment = comment_fixture()
      assert %Ecto.Changeset{} = Blog.change_comment(comment)
    end
  end
end
