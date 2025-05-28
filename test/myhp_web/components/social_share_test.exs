defmodule MyhpWeb.Components.SocialShareTest do
  use MyhpWeb.ConnCase, async: true

  import Phoenix.LiveViewTest
  alias MyhpWeb.Components.SocialShare

  describe "social_share_buttons/1" do
    test "renders social share buttons with correct URLs" do
      assigns = %{
        url: "https://example.com/post",
        title: "Test Post Title"
      }

      html = render_component(&SocialShare.social_share_buttons/1, assigns)

      # Check that all social platforms are included
      assert html =~ "Share:"
      assert html =~ "Twitter"
      assert html =~ "Facebook"
      assert html =~ "LinkedIn"
      assert html =~ "Reddit"
      assert html =~ "Copy"

      # Check that URLs are properly encoded
      assert html =~ "https://twitter.com/intent/tweet"
      assert html =~ "https://www.facebook.com/sharer/sharer.php"
      assert html =~ "https://www.linkedin.com/sharing/share-offsite"
      assert html =~ "https://www.reddit.com/submit"

      # Check URL encoding
      assert html =~ URI.encode("https://example.com/post")
      assert html =~ URI.encode("Test Post Title")
    end

    test "handles special characters in title and URL" do
      assigns = %{
        url: "https://example.com/post with spaces",
        title: "Title with & special chars!"
      }

      html = render_component(&SocialShare.social_share_buttons/1, assigns)

      # Should contain URL-encoded versions (note: HTML may further escape &)
      assert html =~ "https://example.com/post%20with%20spaces"
      assert html =~ "Title%20with%20"
      assert html =~ "special%20chars!"
    end

    test "includes copy link functionality" do
      assigns = %{
        url: "https://example.com/test",
        title: "Test"
      }

      html = render_component(&SocialShare.social_share_buttons/1, assigns)

      assert html =~ ~s(phx-click="copy_link")
      assert html =~ ~s(phx-value-url="https://example.com/test")
    end
  end
end