defmodule MyhpWeb.SitemapController do
  use MyhpWeb, :controller

  alias Myhp.Blog
  alias Myhp.Portfolio

  def sitemap(conn, _params) do
    posts = Blog.list_published_posts()
    projects = Portfolio.list_published_projects()

    conn
    |> put_resp_content_type("application/xml")
    |> render("sitemap.xml", posts: posts, projects: projects)
  end

  def robots(conn, _params) do
    base_url = MyhpWeb.Endpoint.url()

    robots_content = """
    User-agent: *
    Allow: /

    # Sitemap
    Sitemap: #{base_url}/sitemap.xml

    # Disallow admin areas
    Disallow: /admin/
    Disallow: /users/
    Disallow: /dev/

    # Allow important pages
    Allow: /blog/
    Allow: /portfolio/
    Allow: /search
    Allow: /contact
    Allow: /resume
    Allow: /rss
    """

    conn
    |> put_resp_content_type("text/plain")
    |> send_resp(200, robots_content)
  end
end
