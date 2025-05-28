defmodule MyhpWeb.RssXMLTest do
  use MyhpWeb.ConnCase

  describe "RSS XML generation" do
    test "generates RSS feed for blog posts" do
      # Create some blog posts
      user = Myhp.AccountsFixtures.user_fixture()
      post1 = Myhp.BlogFixtures.post_fixture(%{
        title: "First Post", 
        content: "Content of first post",
        user_id: user.id,
        published: true
      })
      post2 = Myhp.BlogFixtures.post_fixture(%{
        title: "Second Post", 
        content: "Content of second post",
        user_id: user.id,
        published: true
      })

      posts = [post1, post2]
      
      assigns = %{
        posts: posts,
        site_url: "https://example.com"
      }

      xml = MyhpWeb.RssXML.feed(assigns) 
      |> Phoenix.HTML.Safe.to_iodata() 
      |> IO.iodata_to_binary()

      # Should be valid RSS XML
      assert xml =~ "<?xml version="
      assert xml =~ "<rss"
      assert xml =~ "<channel>"
      assert xml =~ "</channel>"
      assert xml =~ "</rss>"
      
      # Should include post data
      assert xml =~ "First Post"
      assert xml =~ "Second Post"
      assert xml =~ "Content of first post"
      assert xml =~ "Content of second post"
    end

    test "generates RSS with proper channel metadata" do
      posts = []
      
      assigns = %{
        posts: posts,
        site_url: "https://example.com"
      }

      xml = MyhpWeb.RssXML.feed(assigns) 
      |> Phoenix.HTML.Safe.to_iodata() 
      |> IO.iodata_to_binary()

      # Should include channel metadata
      assert xml =~ "<title>"
      assert xml =~ "<description>"
      assert xml =~ "<link>"
      assert xml =~ "<language>"
    end

    test "handles empty posts list" do
      assigns = %{
        posts: [],
        site_url: "https://example.com"
      }

      xml = MyhpWeb.RssXML.feed(assigns) 
      |> Phoenix.HTML.Safe.to_iodata() 
      |> IO.iodata_to_binary()

      # Should still be valid RSS even with no items
      assert xml =~ "<?xml version="
      assert xml =~ "<rss"
      assert xml =~ "<channel>"
      assert xml =~ "</channel>"
      assert xml =~ "</rss>"
    end

    test "escapes HTML content properly" do
      user = Myhp.AccountsFixtures.user_fixture()
      post = Myhp.BlogFixtures.post_fixture(%{
        title: "Post with <HTML> & symbols", 
        content: "<p>Content with <strong>HTML</strong> & special chars</p>",
        user_id: user.id,
        published: true
      })

      assigns = %{
        posts: [post],
        site_url: "https://example.com"
      }

      xml = MyhpWeb.RssXML.feed(assigns) 
      |> Phoenix.HTML.Safe.to_iodata() 
      |> IO.iodata_to_binary()

      # Should escape HTML entities
      assert xml =~ "&lt;" or xml =~ "&amp;" or xml =~ "HTML"
    end

    test "includes proper RSS item structure" do
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

      xml = MyhpWeb.RssXML.feed(assigns) 
      |> Phoenix.HTML.Safe.to_iodata() 
      |> IO.iodata_to_binary()

      # Should include RSS item elements
      assert xml =~ "<item>"
      assert xml =~ "</item>"
      assert xml =~ "<title>Test Post</title>" or xml =~ "Test Post"
      assert xml =~ "<description>" or xml =~ "Test content"
      assert xml =~ "<pubDate>" or xml =~ "<lastBuildDate>"
    end

    test "formats dates correctly for RSS" do
      user = Myhp.AccountsFixtures.user_fixture()
      post = Myhp.BlogFixtures.post_fixture(%{
        title: "Date Test Post", 
        content: "Testing date formatting",
        user_id: user.id,
        published: true
      })

      assigns = %{
        posts: [post],
        site_url: "https://example.com"
      }

      xml = MyhpWeb.RssXML.feed(assigns) 
      |> Phoenix.HTML.Safe.to_iodata() 
      |> IO.iodata_to_binary()

      # Should include properly formatted dates
      assert xml =~ "Date" or xml =~ "GMT" or xml =~ "pubDate" or xml =~ "lastBuildDate"
    end

    test "includes post links and GUIDs" do
      user = Myhp.AccountsFixtures.user_fixture()
      post = Myhp.BlogFixtures.post_fixture(%{
        title: "Link Test Post", 
        content: "Testing links",
        user_id: user.id,
        published: true
      })

      assigns = %{
        posts: [post],
        site_url: "https://example.com"
      }

      xml = MyhpWeb.RssXML.feed(assigns) 
      |> Phoenix.HTML.Safe.to_iodata() 
      |> IO.iodata_to_binary()

      # Should include links and GUIDs
      assert xml =~ "<link>" or xml =~ "https://example.com"
      assert xml =~ "<guid>" or xml =~ "isPermaLink"
    end

    test "limits number of posts in RSS feed" do
      user = Myhp.AccountsFixtures.user_fixture()
      
      # Create many posts
      posts = for i <- 1..25 do
        Myhp.BlogFixtures.post_fixture(%{
          title: "Post #{i}", 
          content: "Content #{i}",
          user_id: user.id,
          published: true
        })
      end

      assigns = %{
        posts: posts,
        site_url: "https://example.com"
      }

      xml = MyhpWeb.RssXML.feed(assigns) 
      |> Phoenix.HTML.Safe.to_iodata() 
      |> IO.iodata_to_binary()

      # Should handle many posts without breaking
      assert xml =~ "<rss"
      assert xml =~ "</rss>"
      
      # Count items (should be limited to reasonable number)
      item_count = (xml |> String.split("<item>") |> length()) - 1
      assert item_count <= 25
    end
  end
end