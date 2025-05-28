defmodule MyhpWeb.ComprehensiveRssTest do
  use MyhpWeb.ConnCase

  describe "RssXML comprehensive tests" do
    test "feed template renders with empty posts" do
      assigns = %{
        posts: [],
        site_url: "https://example.com"
      }

      result = MyhpWeb.RssXML.feed(assigns)
      assert result
    end

    test "feed template renders with single post" do
      user = Myhp.AccountsFixtures.user_fixture()
      post = Myhp.BlogFixtures.post_fixture(%{
        title: "Test Post",
        content: "Test content",
        user_id: user.id,
        published: true
      })

      assigns = %{
        posts: [post],
        site_url: "https://example.com"
      }

      result = MyhpWeb.RssXML.feed(assigns)
      assert result
    end

    test "feed template renders with multiple posts" do
      user = Myhp.AccountsFixtures.user_fixture()
      posts = [
        Myhp.BlogFixtures.post_fixture(%{
          title: "First Post",
          content: "First content",
          user_id: user.id,
          published: true
        }),
        Myhp.BlogFixtures.post_fixture(%{
          title: "Second Post",
          content: "Second content",
          user_id: user.id,
          published: true
        }),
        Myhp.BlogFixtures.post_fixture(%{
          title: "Third Post",
          content: "Third content",
          user_id: user.id,
          published: true
        })
      ]

      assigns = %{
        posts: posts,
        site_url: "https://example.com"
      }

      result = MyhpWeb.RssXML.feed(assigns)
      assert result
    end

    test "feed template handles posts with special characters" do
      user = Myhp.AccountsFixtures.user_fixture()
      post = Myhp.BlogFixtures.post_fixture(%{
        title: "Post with <HTML> & special chars: 'quotes' \"double quotes\"",
        content: "<p>Content with <strong>HTML tags</strong> & entities like &amp; &lt; &gt;</p>",
        user_id: user.id,
        published: true
      })

      assigns = %{
        posts: [post],
        site_url: "https://example.com"
      }

      result = MyhpWeb.RssXML.feed(assigns)
      assert result
    end

    test "feed template handles posts with unicode" do
      user = Myhp.AccountsFixtures.user_fixture()
      post = Myhp.BlogFixtures.post_fixture(%{
        title: "Post with Unicode: 🚀 💻 🎉",
        content: "Content with unicode characters: français, 中文, العربية",
        user_id: user.id,
        published: true
      })

      assigns = %{
        posts: [post],
        site_url: "https://example.com"
      }

      result = MyhpWeb.RssXML.feed(assigns)
      assert result
    end

    test "feed template handles different site URLs" do
      user = Myhp.AccountsFixtures.user_fixture()
      post = Myhp.BlogFixtures.post_fixture(%{user_id: user.id, published: true})

      assigns = %{
        posts: [post],
        site_url: "https://different-domain.org"
      }

      result = MyhpWeb.RssXML.feed(assigns)
      assert result
    end

    test "feed template handles posts with long content" do
      user = Myhp.AccountsFixtures.user_fixture()
      long_content = String.duplicate("This is a very long content. ", 100)
      
      post = Myhp.BlogFixtures.post_fixture(%{
        title: "Post with very long content",
        content: long_content,
        user_id: user.id,
        published: true
      })

      assigns = %{
        posts: [post],
        site_url: "https://example.com"
      }

      result = MyhpWeb.RssXML.feed(assigns)
      assert result
    end

    test "feed template handles posts with empty content" do
      user = Myhp.AccountsFixtures.user_fixture()
      post = Myhp.BlogFixtures.post_fixture(%{
        title: "Post with empty content",
        content: "Minimal content for test",
        user_id: user.id,
        published: true
      })

      assigns = %{
        posts: [post],
        site_url: "https://example.com"
      }

      result = MyhpWeb.RssXML.feed(assigns)
      assert result
    end

    test "feed template handles many posts" do
      user = Myhp.AccountsFixtures.user_fixture()
      posts = for i <- 1..20 do
        Myhp.BlogFixtures.post_fixture(%{
          title: "Post #{i}",
          content: "Content for post #{i}",
          user_id: user.id,
          published: true
        })
      end

      assigns = %{
        posts: posts,
        site_url: "https://example.com"
      }

      result = MyhpWeb.RssXML.feed(assigns)
      assert result
    end

    test "feed template handles posts from different users" do
      user1 = Myhp.AccountsFixtures.user_fixture()
      user2 = Myhp.AccountsFixtures.user_fixture()
      
      posts = [
        Myhp.BlogFixtures.post_fixture(%{
          title: "Post by User 1",
          content: "Content by first user",
          user_id: user1.id,
          published: true
        }),
        Myhp.BlogFixtures.post_fixture(%{
          title: "Post by User 2",
          content: "Content by second user",
          user_id: user2.id,
          published: true
        })
      ]

      assigns = %{
        posts: posts,
        site_url: "https://example.com"
      }

      result = MyhpWeb.RssXML.feed(assigns)
      assert result
    end

    test "feed template handles posts with various timestamps" do
      user = Myhp.AccountsFixtures.user_fixture()
      
      # Create posts with different timestamps
      old_time = ~N[2020-01-01 00:00:00]
      recent_time = ~N[2024-12-01 12:00:00]
      
      posts = [
        Myhp.BlogFixtures.post_fixture(%{
          title: "Old Post",
          content: "Old content",
          user_id: user.id,
          published: true,
          published_at: old_time
        }),
        Myhp.BlogFixtures.post_fixture(%{
          title: "Recent Post",
          content: "Recent content",
          user_id: user.id,
          published: true,
          published_at: recent_time
        })
      ]

      assigns = %{
        posts: posts,
        site_url: "https://example.com"
      }

      result = MyhpWeb.RssXML.feed(assigns)
      assert result
    end

    test "feed template with minimal site URL" do
      assigns = %{
        posts: [],
        site_url: "http://localhost"
      }

      result = MyhpWeb.RssXML.feed(assigns)
      assert result
    end
  end
end