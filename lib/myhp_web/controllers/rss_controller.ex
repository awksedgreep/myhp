defmodule MyhpWeb.RssController do
  use MyhpWeb, :controller

  alias Myhp.Blog

  def feed(conn, _params) do
    posts = Blog.list_published_posts() |> Enum.take(20)
    xml_content = MyhpWeb.RssXML.render("feed.xml", %{posts: posts})

    conn
    |> put_resp_content_type("text/xml")
    |> send_resp(200, xml_content)
  end
end
