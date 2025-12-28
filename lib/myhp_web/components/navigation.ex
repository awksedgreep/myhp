defmodule MyhpWeb.Components.Navigation do
  use Phoenix.Component
  use MyhpWeb, :verified_routes

  attr :current_user, :any, default: nil

  def navbar(assigns) do
    ~H"""
    <nav class="bg-white dark:bg-gray-800 shadow-sm border-b border-gray-200 dark:border-gray-700 transition-colors" x-data="{ currentPath: window.location.pathname }" x-init="
      // Update currentPath when the URL changes (for LiveView navigation)
      window.addEventListener('phx:page-loading-stop', () => {
        currentPath = window.location.pathname;
      });
    ">
      <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div class="flex justify-between h-16">
          <!-- Left side - Logo/Brand -->
          <div class="flex items-center">
            <.link navigate={~p"/"} class="flex items-center">
              <span class="text-2xl font-bold text-gray-900 dark:text-white">Mark Cotner</span>
            </.link>
          </div>

    <!-- Center - Main Navigation -->
          <div class="hidden md:flex items-center space-x-8">
            <.nav_link href={~p"/"}>
              Home
            </.nav_link>
            <.nav_link href={~p"/blog"}>
              Blog
            </.nav_link>
            <.nav_link href={~p"/portfolio"}>
              Portfolio
            </.nav_link>
            <.nav_link href={~p"/resume"}>
              Resume
            </.nav_link>
            <.nav_link href={~p"/search"}>
              Search
            </.nav_link>
            <.nav_link href={~p"/contact"}>
              Contact
            </.nav_link>

    <!-- Authenticated only links -->
            <%= if @current_user do %>
              <.nav_link href={~p"/chat"}>
                Chat
              </.nav_link>
              <.nav_link href={~p"/activity"}>
                Activity
              </.nav_link>
            <% end %>
          </div>

    <!-- Right side - User menu -->
          <div class="flex items-center space-x-4">
            <!-- Phoenix Logo (Easter Egg) -->
            <.link navigate={~p"/phoenix"} class="flex items-center" title="What's this?">
              <img src={~p"/images/logo.svg"} width="24" height="24" alt="Phoenix Framework" class="opacity-60 hover:opacity-100 hover:scale-110 transition-all duration-200" />
            </.link>

            <!-- Theme toggle -->
            <button
              @click="toggleTheme()"
              class="p-2 text-gray-500 hover:text-gray-700 dark:text-gray-400 dark:hover:text-gray-300 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-offset-2 rounded-md transition-colors"
              title="Toggle theme"
            >
              <!-- Sun icon for dark mode (shown when dark mode is active) -->
              <svg
                x-show="$parent.darkMode"
                class="w-5 h-5"
                fill="none"
                stroke="currentColor"
                viewBox="0 0 24 24"
              >
                <path
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  stroke-width="2"
                  d="M12 3v1m0 16v1m9-9h-1M4 12H3m15.364 6.364l-.707-.707M6.343 6.343l-.707-.707m12.728 0l-.707.707M6.343 17.657l-.707.707M16 12a4 4 0 11-8 0 4 4 0 018 0z"
                >
                </path>
              </svg>
              <!-- Moon icon for light mode (shown when light mode is active) -->
              <svg
                x-show="!$parent.darkMode"
                class="w-5 h-5"
                fill="none"
                stroke="currentColor"
                viewBox="0 0 24 24"
              >
                <path
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  stroke-width="2"
                  d="M20.354 15.354A9 9 0 018.646 3.646 9.003 9.003 0 0012 21a9.003 9.003 0 008.354-5.646z"
                >
                </path>
              </svg>
            </button>

            <%= if @current_user do %>
              <!-- User dropdown -->
              <div class="relative" x-data="{ open: false }">
                <button
                  @click="open = !open"
                  class="flex items-center text-sm rounded-full focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-offset-2"
                >
                  <div class="w-8 h-8 bg-gray-300 rounded-full flex items-center justify-center">
                    <span class="text-sm font-medium text-gray-700">
                      {String.at(@current_user.email, 0) |> String.upcase()}
                    </span>
                  </div>
                </button>

                <div
                  x-show="open"
                  @click.away="open = false"
                  x-transition:enter="transition ease-out duration-100"
                  x-transition:enter-start="transform opacity-0 scale-95"
                  x-transition:enter-end="transform opacity-100 scale-100"
                  x-transition:leave="transition ease-in duration-75"
                  x-transition:leave-start="transform opacity-100 scale-100"
                  x-transition:leave-end="transform opacity-0 scale-95"
                  class="absolute right-0 mt-2 w-64 bg-white dark:bg-gray-800 rounded-md shadow-lg py-1 z-50 border dark:border-gray-700"
                >
                  <div class="px-4 py-2 text-sm text-gray-700 dark:text-gray-300 border-b border-gray-200 dark:border-gray-600">
                    {@current_user.email}
                  </div>
                  <.link
                    href={~p"/users/settings"}
                    class="block px-4 py-2 text-sm text-gray-700 dark:text-gray-300 hover:bg-gray-100 dark:hover:bg-gray-700"
                  >
                    Settings
                  </.link>
                  <%= if @current_user.admin do %>
                    <.link
                      href={~p"/admin"}
                      class="block px-4 py-2 text-sm text-gray-700 dark:text-gray-300 hover:bg-gray-100 dark:hover:bg-gray-700"
                    >
                      Admin
                    </.link>
                  <% end %>
                  <.link
                    href={~p"/users/log_out"}
                    method="delete"
                    class="block px-4 py-2 text-sm text-gray-700 dark:text-gray-300 hover:bg-gray-100 dark:hover:bg-gray-700"
                  >
                    Sign out
                  </.link>
                </div>
              </div>
            <% else %>
              <!-- Login/Register buttons -->
              <.link
                href={~p"/users/log_in"}
                class="text-gray-700 dark:text-gray-300 hover:text-gray-900 dark:hover:text-white px-3 py-2 text-sm font-medium"
              >
                Sign in
              </.link>
              <.link
                href={~p"/users/register"}
                class="bg-blue-600 hover:bg-blue-700 text-white px-4 py-2 rounded-md text-sm font-medium transition-colors"
              >
                Sign up
              </.link>
            <% end %>

    <!-- Mobile menu button -->
            <button
              class="md:hidden p-2 text-gray-500 hover:text-gray-700 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-offset-2 rounded-md"
              x-data
              @click="$dispatch('toggle-mobile-menu')"
            >
              <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  stroke-width="2"
                  d="M4 6h16M4 12h16M4 18h16"
                >
                </path>
              </svg>
            </button>
          </div>
        </div>
      </div>

    <!-- Mobile menu -->
      <div
        class="md:hidden"
        x-data="{ open: false }"
        @toggle-mobile-menu.window="open = !open"
        x-show="open"
        x-transition:enter="transition ease-out duration-200"
        x-transition:enter-start="opacity-0 scale-95"
        x-transition:enter-end="opacity-100 scale-100"
        x-transition:leave="transition ease-in duration-150"
        x-transition:leave-start="opacity-100 scale-100"
        x-transition:leave-end="opacity-0 scale-95"
      >
        <div class="px-2 pt-2 pb-3 space-y-1 sm:px-3 bg-white dark:bg-gray-800 border-t border-gray-200 dark:border-gray-700">
          <.mobile_nav_link href={~p"/"}>
            Home
          </.mobile_nav_link>
          <.mobile_nav_link href={~p"/blog"}>
            Blog
          </.mobile_nav_link>
          <.mobile_nav_link href={~p"/portfolio"}>
            Portfolio
          </.mobile_nav_link>
          <.mobile_nav_link href={~p"/contact"}>
            Contact
          </.mobile_nav_link>

          <%= if @current_user do %>
            <.mobile_nav_link href={~p"/chat"}>
              Chat
            </.mobile_nav_link>
          <% end %>
        </div>
      </div>
    </nav>
    """
  end

  attr :href, :string, required: true
  slot :inner_block, required: true

  defp nav_link(assigns) do
    ~H"""
    <.link
      navigate={@href}
      class="px-3 py-2 text-sm font-medium transition-colors duration-200"
      {%{
        "x-bind:class" =>
          if @href == "/" do
            "(currentPath === '#{@href}') ? 'text-blue-600 dark:text-blue-400 border-b-2 border-blue-600 dark:border-blue-400' : 'text-gray-700 dark:text-gray-300 hover:text-blue-600 dark:hover:text-blue-400'"
          else
            "(currentPath.startsWith('#{@href}')) ? 'text-blue-600 dark:text-blue-400 border-b-2 border-blue-600 dark:border-blue-400' : 'text-gray-700 dark:text-gray-300 hover:text-blue-600 dark:hover:text-blue-400'"
          end
      }}
    >
      {render_slot(@inner_block)}
    </.link>
    """
  end

  attr :href, :string, required: true
  slot :inner_block, required: true

  defp mobile_nav_link(assigns) do
    ~H"""
    <.link
      navigate={@href}
      class="block px-3 py-2 text-base font-medium transition-colors duration-200"
      {%{
        "x-bind:class" =>
          if @href == "/" do
            "(currentPath === '#{@href}') ? 'text-blue-600 dark:text-blue-400 bg-blue-50 dark:bg-blue-900/20' : 'text-gray-700 dark:text-gray-300 hover:text-blue-600 dark:hover:text-blue-400 hover:bg-gray-50 dark:hover:bg-gray-700'"
          else
            "(currentPath.startsWith('#{@href}')) ? 'text-blue-600 dark:text-blue-400 bg-blue-50 dark:bg-blue-900/20' : 'text-gray-700 dark:text-gray-300 hover:text-blue-600 dark:hover:text-blue-400 hover:bg-gray-50 dark:hover:bg-gray-700'"
          end
      }}
    >
      {render_slot(@inner_block)}
    </.link>
    """
  end
end
