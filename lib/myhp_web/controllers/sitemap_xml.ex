defmodule MyhpWeb.SitemapXML do
  use MyhpWeb, :html

  embed_templates "sitemap_xml/*"

  defp format_datetime(%DateTime{} = datetime) do
    datetime
    |> DateTime.truncate(:second)
    |> DateTime.to_iso8601()
  end

  defp format_datetime(%NaiveDateTime{} = naive_datetime) do
    naive_datetime
    |> DateTime.from_naive!("Etc/UTC")
    |> DateTime.truncate(:second)
    |> DateTime.to_iso8601()
  end

  defp format_datetime(nil), do: DateTime.utc_now() |> DateTime.to_iso8601()
end
