defmodule MyhpWeb.RssXML do
  @moduledoc """
  RSS XML rendering module
  """

  def feed(assigns) do
    {:safe, render("feed.xml", assigns)}
  end

  def render("feed.xml", %{posts: posts}) do
    xml = """
    <?xml version="1.0" encoding="UTF-8"?>
    <rss version="2.0" xmlns:atom="http://www.w3.org/2005/Atom">
      <channel>
        <title>MyHP - Personal Blog</title>
        <description>Latest blog posts from my personal homepage</description>
        <link>#{MyhpWeb.Endpoint.url()}/blog</link>
        <atom:link href="#{MyhpWeb.Endpoint.url()}/rss" rel="self" type="application/rss+xml"/>
        <language>en-us</language>
        <lastBuildDate>#{DateTime.utc_now() |> Calendar.strftime("%a, %d %b %Y %H:%M:%S GMT")}</lastBuildDate>
        <generator>Phoenix LiveView</generator>

        #{Enum.map(posts, &render_item/1) |> Enum.join("\n    ")}
      </channel>
    </rss>
    """
    
    # For controller use, return plain binary
    String.trim(xml)
  end

  defp render_item(post) do
    """
    <item>
      <title>#{escape_xml(post.title)}</title>
      <link>#{MyhpWeb.Endpoint.url()}/blog/#{post.id}</link>
      <description><![CDATA[#{post.content}]]></description>
      <pubDate>#{Calendar.strftime(post.inserted_at, "%a, %d %b %Y %H:%M:%S GMT")}</pubDate>
      <guid>#{MyhpWeb.Endpoint.url()}/blog/#{post.id}</guid>
    </item>
    """
  end

  defp escape_xml(text) do
    text
    |> String.replace("&", "&amp;")
    |> String.replace("<", "&lt;")
    |> String.replace(">", "&gt;")
    |> String.replace("\"", "&quot;")
    |> String.replace("'", "&apos;")
  end
end
