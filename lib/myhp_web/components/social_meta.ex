defmodule MyhpWeb.Components.SocialMeta do
  use Phoenix.Component

  def social_meta_tags(assigns) do
    ~H"""
    <!-- Open Graph / Facebook -->
    <meta property="og:type" content={@type || "website"} />
    <meta property="og:url" content={@url} />
    <meta property="og:title" content={@title} />
    <meta property="og:description" content={@description} />
    <meta property="og:image" content={@image || default_image()} />
    <meta property="og:site_name" content="My Homepage" />

    <!-- Twitter -->
    <meta property="twitter:card" content="summary_large_image" />
    <meta property="twitter:url" content={@url} />
    <meta property="twitter:title" content={@title} />
    <meta property="twitter:description" content={@description} />
    <meta property="twitter:image" content={@image || default_image()} />

    <!-- LinkedIn -->
    <meta property="linkedin:card" content="summary" />
    <meta property="linkedin:site" content="@myhandle" />
    <meta property="linkedin:creator" content="@myhandle" />

    <!-- Additional meta tags -->
    <meta name="description" content={@description} />
    <meta name="keywords" content={@keywords || "blog, portfolio, development"} />
    <meta name="author" content="Your Name" />

    <!-- Canonical URL -->
    <link rel="canonical" href={@url} />
    """
  end

  defp default_image do
    # Return a default og:image URL
    "/images/default-og-image.png"
  end
end
