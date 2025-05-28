defmodule MyhpWeb.SitemapControllerTest do
  use MyhpWeb.ConnCase

  describe "GET /sitemap.xml" do
    test "returns XML sitemap with published content", %{conn: conn} do
      # Create published blog post
      post = Myhp.BlogFixtures.post_fixture(%{
        title: "Test Blog Post",
        content: "Test content",
        published: true
      })
      
      # Create published project
      project = Myhp.PortfolioFixtures.project_fixture(%{
        title: "Test Project",
        published: true
      })
      
      # Create unpublished content (should not appear)
      _draft_post = Myhp.BlogFixtures.post_fixture(%{
        title: "Draft Post",
        content: "Draft content", 
        published: false
      })
      
      _draft_project = Myhp.PortfolioFixtures.project_fixture(%{
        title: "Draft Project",
        published: false
      })

      conn = get(conn, ~p"/sitemap.xml")
      
      response = response(conn, 200)
      
      # Check content type
      assert get_resp_header(conn, "content-type") == ["application/xml; charset=utf-8"]
      
      # Check XML structure
      assert response =~ "<?xml"
      assert response =~ "<urlset"
      assert response =~ "xmlns=\"http://www.sitemaps.org/schemas/sitemap/0.9\""
      
      # Check static pages are included
      assert response =~ "<loc>http://localhost:4002/</loc>"
      assert response =~ "<loc>http://localhost:4002/blog</loc>"
      assert response =~ "<loc>http://localhost:4002/portfolio</loc>"
      assert response =~ "<loc>http://localhost:4002/contact</loc>"
      assert response =~ "<loc>http://localhost:4002/resume</loc>"
      
      # Check published content is included
      assert response =~ "/blog/#{post.id}"
      assert response =~ "/portfolio/#{project.id}"
      
      # Check unpublished content is not included
      refute response =~ "Draft Post"
      refute response =~ "Draft Project"
    end

    test "returns valid sitemap when no published content exists", %{conn: conn} do
      conn = get(conn, ~p"/sitemap.xml")
      
      response = response(conn, 200)
      
      assert get_resp_header(conn, "content-type") == ["application/xml; charset=utf-8"]
      assert response =~ "<?xml"
      assert response =~ "<urlset"
      
      # Should still include static pages
      assert response =~ "<loc>http://localhost:4002/</loc>"
      assert response =~ "<loc>http://localhost:4002/blog</loc>"
    end
  end

  describe "GET /robots.txt" do
    test "returns robots.txt with proper directives", %{conn: conn} do
      conn = get(conn, ~p"/robots.txt")
      
      response = response(conn, 200)
      
      # Check content type
      assert get_resp_header(conn, "content-type") == ["text/plain; charset=utf-8"]
      
      # Check required directives
      assert response =~ "User-agent: *"
      assert response =~ "Allow: /"
      assert response =~ "Sitemap: http://localhost:4002/sitemap.xml"
      
      # Check admin areas are disallowed
      assert response =~ "Disallow: /admin/"
      assert response =~ "Disallow: /users/"
      assert response =~ "Disallow: /dev/"
      
      # Check important pages are explicitly allowed
      assert response =~ "Allow: /blog/"
      assert response =~ "Allow: /portfolio/"
      assert response =~ "Allow: /search"
      assert response =~ "Allow: /contact"
      assert response =~ "Allow: /resume"
      assert response =~ "Allow: /rss"
    end

    test "includes correct base URL in sitemap directive", %{conn: conn} do
      conn = get(conn, ~p"/robots.txt")
      
      response = response(conn, 200)
      
      # Should use the endpoint URL configured in test
      assert response =~ "Sitemap: http://localhost:4002/sitemap.xml"
    end
  end
end