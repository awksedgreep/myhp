defmodule MyhpWeb.Components.SocialMetaTest do
  use MyhpWeb.ConnCase, async: true

  import Phoenix.LiveViewTest
  alias MyhpWeb.Components.SocialMeta

  describe "social_meta_tags/1" do
    test "renders all required meta tags" do
      assigns = %{
        url: "https://example.com/page",
        title: "Page Title",
        description: "Page description",
        type: "article",
        image: "https://example.com/image.jpg",
        keywords: "test, meta, tags"
      }

      html = render_component(&SocialMeta.social_meta_tags/1, assigns)

      # Open Graph tags
      assert html =~ ~s(property="og:type" content="article")
      assert html =~ ~s(property="og:url" content="https://example.com/page")
      assert html =~ ~s(property="og:title" content="Page Title")
      assert html =~ ~s(property="og:description" content="Page description")
      assert html =~ ~s(property="og:image" content="https://example.com/image.jpg")
      assert html =~ ~s(property="og:site_name" content="My Homepage")

      # Twitter tags
      assert html =~ ~s(property="twitter:card" content="summary_large_image")
      assert html =~ ~s(property="twitter:url" content="https://example.com/page")
      assert html =~ ~s(property="twitter:title" content="Page Title")
      assert html =~ ~s(property="twitter:description" content="Page description")
      assert html =~ ~s(property="twitter:image" content="https://example.com/image.jpg")

      # LinkedIn tags
      assert html =~ ~s(property="linkedin:card" content="summary")
      assert html =~ ~s(property="linkedin:site" content="@myhandle")
      assert html =~ ~s(property="linkedin:creator" content="@myhandle")

      # Additional meta tags
      assert html =~ ~s(name="description" content="Page description")
      assert html =~ ~s(name="keywords" content="test, meta, tags")
      assert html =~ ~s(name="author" content="Your Name")

      # Canonical URL
      assert html =~ ~s(rel="canonical" href="https://example.com/page")
    end

    test "uses default values when optional fields are missing" do
      assigns = %{
        url: "https://example.com/page",
        title: "Page Title",
        description: "Page description",
        type: nil,
        image: nil,
        keywords: nil
      }

      html = render_component(&SocialMeta.social_meta_tags/1, assigns)

      # Should use default type
      assert html =~ ~s(property="og:type" content="website")

      # Should use default image
      assert html =~ ~s(property="og:image" content="/images/default-og-image.png")
      assert html =~ ~s(property="twitter:image" content="/images/default-og-image.png")

      # Should use default keywords
      assert html =~ ~s(name="keywords" content="blog, portfolio, development")
    end

    test "handles nil values gracefully" do
      assigns = %{
        url: "https://example.com/page",
        title: "Page Title",
        description: "Page description",
        type: nil,
        image: nil,
        keywords: nil
      }

      html = render_component(&SocialMeta.social_meta_tags/1, assigns)

      # Should still render with defaults
      assert html =~ ~s(property="og:type" content="website")
      assert html =~ ~s(property="og:image" content="/images/default-og-image.png")
      assert html =~ ~s(name="keywords" content="blog, portfolio, development")
    end
  end
end