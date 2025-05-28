defmodule MyhpWeb.Admin.SocialLive do
  use MyhpWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    social_links = get_social_links()

    {:ok,
     socket
     |> assign(:page_title, "Social Media Settings")
     |> assign(:current_page, "admin")
     |> assign(:social_links, social_links)
     |> assign(:form, to_form(social_links))}
  end

  @impl true
  def handle_event("save_social", %{"social" => social_params}, socket) do
    {:ok, social_links} = save_social_links(social_params)

    {:noreply,
     socket
     |> assign(:social_links, social_links)
     |> assign(:form, to_form(social_links))
     |> put_flash(:info, "Social media links updated successfully!")}
  end

  @impl true
  def handle_event("test_share", %{"platform" => platform}, socket) do
    test_url = MyhpWeb.Endpoint.url() <> "/blog"

    share_url =
      case platform do
        "twitter" ->
          "https://twitter.com/intent/tweet?url=#{URI.encode(test_url)}&text=Check out my blog!"

        "facebook" ->
          "https://www.facebook.com/sharer/sharer.php?u=#{URI.encode(test_url)}"

        "linkedin" ->
          "https://www.linkedin.com/sharing/share-offsite/?url=#{URI.encode(test_url)}&title=My Blog"

        _ ->
          test_url
      end

    {:noreply,
     socket
     |> push_event("open_url", %{url: share_url})
     |> put_flash(:info, "Opening #{platform} share dialog...")}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="max-w-4xl mx-auto p-6">
      <div class="mb-8">
        <h1 class="text-3xl font-bold text-gray-900 mb-2">Social Media Settings</h1>
        <p class="text-gray-600">Configure your social media profiles and sharing settings.</p>
      </div>

      <div class="bg-white rounded-lg shadow-sm border border-gray-200 p-6 mb-8">
        <h2 class="text-xl font-semibold text-gray-900 mb-4">Social Media Profiles</h2>

        <.form for={@form} phx-submit="save_social" class="space-y-6">
          <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-2">
                Twitter/X Username
              </label>
              <div class="flex">
                <span class="inline-flex items-center px-3 py-2 border border-r-0 border-gray-300 bg-gray-50 text-gray-500 text-sm rounded-l-md">
                  @
                </span>
                <input
                  type="text"
                  name="social[twitter]"
                  value={@social_links[:twitter] || @social_links["twitter"] || ""}
                  placeholder="username"
                  class="flex-1 min-w-0 px-3 py-2 border border-gray-300 rounded-r-md focus:ring-blue-500 focus:border-blue-500"
                />
              </div>
            </div>

            <div>
              <label class="block text-sm font-medium text-gray-700 mb-2">
                LinkedIn Profile
              </label>
              <div class="flex">
                <span class="inline-flex items-center px-3 py-2 border border-r-0 border-gray-300 bg-gray-50 text-gray-500 text-sm rounded-l-md">
                  linkedin.com/in/
                </span>
                <input
                  type="text"
                  name="social[linkedin]"
                  value={@social_links[:linkedin] || @social_links["linkedin"] || ""}
                  placeholder="username"
                  class="flex-1 min-w-0 px-3 py-2 border border-gray-300 rounded-r-md focus:ring-blue-500 focus:border-blue-500"
                />
              </div>
            </div>

            <div>
              <label class="block text-sm font-medium text-gray-700 mb-2">
                GitHub Username
              </label>
              <div class="flex">
                <span class="inline-flex items-center px-3 py-2 border border-r-0 border-gray-300 bg-gray-50 text-gray-500 text-sm rounded-l-md">
                  github.com/
                </span>
                <input
                  type="text"
                  name="social[github]"
                  value={@social_links[:github] || @social_links["github"] || ""}
                  placeholder="username"
                  class="flex-1 min-w-0 px-3 py-2 border border-gray-300 rounded-r-md focus:ring-blue-500 focus:border-blue-500"
                />
              </div>
            </div>

            <div>
              <label class="block text-sm font-medium text-gray-700 mb-2">
                Personal Website
              </label>
              <input
                type="url"
                name="social[website]"
                value={@social_links[:website] || @social_links["website"] || ""}
                placeholder="https://yoursite.com"
                class="w-full px-3 py-2 border border-gray-300 rounded-md focus:ring-blue-500 focus:border-blue-500"
              />
            </div>
          </div>

          <div class="flex justify-end">
            <button
              type="submit"
              class="px-4 py-2 bg-blue-600 text-white rounded-md hover:bg-blue-700 font-medium transition-colors"
            >
              Save Social Links
            </button>
          </div>
        </.form>
      </div>

      <div class="bg-white rounded-lg shadow-sm border border-gray-200 p-6 mb-8">
        <h2 class="text-xl font-semibold text-gray-900 mb-4">Test Social Sharing</h2>
        <p class="text-gray-600 mb-4">
          Test how your content appears when shared on social media platforms.
        </p>

        <div class="flex flex-wrap gap-3">
          <button
            phx-click="test_share"
            phx-value-platform="twitter"
            class="inline-flex items-center px-4 py-2 bg-blue-500 text-white rounded-md hover:bg-blue-600 font-medium transition-colors"
          >
            Test Twitter Share
          </button>

          <button
            phx-click="test_share"
            phx-value-platform="facebook"
            class="inline-flex items-center px-4 py-2 bg-blue-600 text-white rounded-md hover:bg-blue-700 font-medium transition-colors"
          >
            Test Facebook Share
          </button>

          <button
            phx-click="test_share"
            phx-value-platform="linkedin"
            class="inline-flex items-center px-4 py-2 bg-blue-700 text-white rounded-md hover:bg-blue-800 font-medium transition-colors"
          >
            Test LinkedIn Share
          </button>
        </div>
      </div>

      <div class="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
        <h2 class="text-xl font-semibold text-gray-900 mb-4">Social Media Integration Status</h2>

        <div class="space-y-3">
          <div class="flex items-center justify-between p-3 bg-green-50 border border-green-200 rounded-md">
            <div class="flex items-center">
              <svg class="w-5 h-5 text-green-500 mr-3" fill="currentColor" viewBox="0 0 20 20">
                <path
                  fill-rule="evenodd"
                  d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z"
                  clip-rule="evenodd"
                />
              </svg>
              <span class="text-green-800 font-medium">Open Graph Meta Tags</span>
            </div>
            <span class="text-green-600 text-sm">Active</span>
          </div>

          <div class="flex items-center justify-between p-3 bg-green-50 border border-green-200 rounded-md">
            <div class="flex items-center">
              <svg class="w-5 h-5 text-green-500 mr-3" fill="currentColor" viewBox="0 0 20 20">
                <path
                  fill-rule="evenodd"
                  d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z"
                  clip-rule="evenodd"
                />
              </svg>
              <span class="text-green-800 font-medium">Social Share Buttons</span>
            </div>
            <span class="text-green-600 text-sm">Active</span>
          </div>

          <div class="flex items-center justify-between p-3 bg-green-50 border border-green-200 rounded-md">
            <div class="flex items-center">
              <svg class="w-5 h-5 text-green-500 mr-3" fill="currentColor" viewBox="0 0 20 20">
                <path
                  fill-rule="evenodd"
                  d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z"
                  clip-rule="evenodd"
                />
              </svg>
              <span class="text-green-800 font-medium">Twitter Cards</span>
            </div>
            <span class="text-green-600 text-sm">Active</span>
          </div>
        </div>
      </div>
    </div>
    """
  end

  defp get_social_links do
    # In a real app, you'd store this in the database
    # For now, return some defaults
    %{
      "twitter" => "",
      "linkedin" => "",
      "github" => "",
      "website" => ""
    }
  end

  defp save_social_links(params) do
    # In a real app, you'd save this to the database
    # For now, just return success
    {:ok, params}
  end
end
