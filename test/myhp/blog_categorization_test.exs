defmodule Myhp.BlogCategorizationTest do
  use Myhp.DataCase
  alias Myhp.Blog
  alias Myhp.Blog.{Post, Category, Tag}

  describe "post categorization" do
    setup do
      user = Myhp.AccountsFixtures.user_fixture()
      
      category = %Category{}
      |> Category.changeset(%{name: "Technology", description: "Tech posts"})
      |> Repo.insert!()
      
      tag1 = %Tag{}
      |> Tag.changeset(%{name: "elixir"})
      |> Repo.insert!()
      
      tag2 = %Tag{}
      |> Tag.changeset(%{name: "phoenix"}) 
      |> Repo.insert!()

      %{user: user, category: category, tag1: tag1, tag2: tag2}
    end

    test "post can be assigned to a category", %{user: _user, category: category} do
      attrs = %{
        title: "Test Post",
        content: "Test content",
        published: true,
        category_id: category.id
      }

      assert {:ok, post} = Blog.create_post(attrs)
      assert post.category_id == category.id
      
      post = Repo.preload(post, :category)
      assert post.category.name == "Technology"
    end

    test "post can have multiple tags", %{user: _user, tag1: tag1, tag2: tag2} do
      attrs = %{
        title: "Test Post", 
        content: "Test content",
        published: true,
        tag_ids: [tag1.id, tag2.id]
      }

      assert {:ok, post} = Blog.create_post(attrs)
      
      post = Repo.preload(post, :tags)
      tag_names = Enum.map(post.tags, & &1.name)
      assert "elixir" in tag_names
      assert "phoenix" in tag_names
    end

    test "posts can be filtered by category", %{user: _user, category: category} do
      post1 = Myhp.BlogFixtures.post_fixture(%{
        category_id: category.id,
        published: true
      })
      
      _post2 = Myhp.BlogFixtures.post_fixture(%{
        published: true
      })

      posts = Blog.list_posts_by_category(category.id)
      assert length(posts) == 1
      assert hd(posts).id == post1.id
    end

    test "posts can be filtered by tag", %{user: _user, tag1: tag1, tag2: tag2} do
      post1 = Myhp.BlogFixtures.post_fixture(%{
        published: true
      })
      Blog.add_tags_to_post(post1, [tag1.id])
      
      post2 = Myhp.BlogFixtures.post_fixture(%{
        published: true
      })
      Blog.add_tags_to_post(post2, [tag1.id, tag2.id])
      
      _post3 = Myhp.BlogFixtures.post_fixture(%{
        published: true
      })

      posts = Blog.list_posts_by_tag(tag1.id)
      assert length(posts) == 2
      
      post_ids = Enum.map(posts, & &1.id)
      assert post1.id in post_ids
      assert post2.id in post_ids
    end

    test "can get popular tags", %{user: _user, tag1: tag1, tag2: tag2} do
      # Create posts with tags
      for _ <- 1..3 do
        post = Myhp.BlogFixtures.post_fixture(%{published: true})
        Blog.add_tags_to_post(post, [tag1.id])
      end
      
      for _ <- 1..2 do
        post = Myhp.BlogFixtures.post_fixture(%{published: true})
        Blog.add_tags_to_post(post, [tag2.id])
      end

      popular_tags = Blog.get_popular_tags(10)
      assert length(popular_tags) == 2
      
      # Tag1 should be first (3 posts vs 2 posts)
      assert hd(popular_tags).name == tag1.name
    end

    test "can get categories with post counts", %{user: _user, category: category} do
      # Create posts in category
      for _ <- 1..2 do
        Myhp.BlogFixtures.post_fixture(%{
          category_id: category.id,
          published: true
        })
      end

      categories = Blog.get_categories_with_counts()
      assert length(categories) == 1
      
      category_data = hd(categories)
      assert category_data.name == "Technology"
      assert category_data.post_count == 2
    end

    test "category deletion removes association from posts", %{user: _user, category: category} do
      post = Myhp.BlogFixtures.post_fixture(%{
        category_id: category.id,
        published: true
      })

      Repo.delete!(category)
      
      updated_post = Repo.get!(Post, post.id)
      assert updated_post.category_id == nil
    end

    test "tag deletion removes many-to-many associations", %{user: _user, tag1: tag1} do
      post = Myhp.BlogFixtures.post_fixture(%{published: true})
      Blog.add_tags_to_post(post, [tag1.id])
      
      post = Repo.preload(post, :tags, force: true)
      assert length(post.tags) == 1

      Repo.delete!(tag1)
      
      post = Repo.preload(post, :tags, force: true)
      assert length(post.tags) == 0
    end
  end
end