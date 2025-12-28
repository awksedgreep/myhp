defmodule MyhpWeb.Router do
  use MyhpWeb, :router

  import MyhpWeb.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {MyhpWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_user
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", MyhpWeb do
    pipe_through :browser

    get "/", PageController, :home

    # RSS feed
    get "/rss", RssController, :feed
    get "/feed", RssController, :feed

    # SEO
    get "/sitemap.xml", SitemapController, :sitemap
    get "/robots.txt", SitemapController, :robots

    # Resume/CV routes
    get "/resume", ResumeController, :index
    get "/resume/view", ResumeController, :view
    get "/resume/download", ResumeController, :download
    get "/cv", ResumeController, :index
    get "/cv/view", ResumeController, :view
    get "/cv/download", ResumeController, :download
  end

  # Authenticated live routes (must come before public routes with :id params)
  live_session :authenticated, on_mount: [{MyhpWeb.UserAuth, :ensure_authenticated}] do
    scope "/", MyhpWeb do
      pipe_through [:browser, :require_authenticated_user]

      # Admin blog routes (require authentication)
      live "/blog/new", PostLive.Index, :new
      live "/blog/:id/edit", PostLive.Index, :edit
      live "/blog/:id/show/edit", PostLive.Show, :edit

      # Admin portfolio routes (require authentication)
      live "/portfolio/new", ProjectLive.Index, :new
      live "/portfolio/:id/edit", ProjectLive.Index, :edit
      live "/portfolio/:id/show/edit", ProjectLive.Show, :edit

      # Admin file management routes (require authentication)
      live "/admin/files", UploadedFileLive.Index, :index
      live "/admin/files/new", UploadedFileLive.Index, :new
      live "/admin/files/:id/edit", UploadedFileLive.Index, :edit

      # Admin contact message routes (require authentication)
      live "/admin/contact-messages", ContactMessageLive.Index, :index
      live "/admin/contact-messages/:id", ContactMessageLive.Show, :show
      live "/admin/contact-messages/:id/edit", ContactMessageLive.Index, :edit

      # Admin user management routes (require authentication)
      live "/admin/users", Admin.UserLive, :index
      live "/admin/users/:id", Admin.UserLive, :show

      # Admin analytics routes (require authentication)
      live "/admin/analytics", Admin.AnalyticsLive, :index

      # Admin social media routes (require authentication)
      live "/admin/social", Admin.SocialLive, :index

      # Chat route (require authentication)
      live "/chat", MessageLive.Index, :index

      # Activity feed (require authentication)
      live "/activity", ActivityLive, :index

      # Notifications (require authentication)
      live "/notifications", NotificationLive, :index
    end
  end

  # Public live routes (with user detection)
  live_session :public, on_mount: [{MyhpWeb.UserAuth, :mount_current_user}] do
    scope "/", MyhpWeb do
      pipe_through :browser

      # Public blog routes
      live "/blog", PostLive.Index, :index
      live "/blog/:id", PostLive.Show, :show

      # Search
      live "/search", SearchLive, :index

      # Public portfolio routes
      live "/portfolio", ProjectLive.Index, :index
      live "/portfolio/:id", ProjectLive.Show, :show

      # Public contact route
      live "/contact", ContactMessageLive.Index, :new

      # Easter egg
      live "/phoenix", PhoenixLive, :index
    end
  end

  # API routes
  scope "/api", MyhpWeb do
    pipe_through :api

    get "/blog", ApiController, :blog
    get "/users", ApiController, :users
    get "/search", ApiController, :search
  end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:myhp, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: MyhpWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

  ## Authentication routes

  scope "/", MyhpWeb do
    pipe_through [:browser, :redirect_if_user_is_authenticated]

    get "/users/register", UserRegistrationController, :new
    post "/users/register", UserRegistrationController, :create
    get "/users/log_in", UserSessionController, :new
    post "/users/log_in", UserSessionController, :create
    get "/users/reset_password", UserResetPasswordController, :new
    post "/users/reset_password", UserResetPasswordController, :create
    get "/users/reset_password/:token", UserResetPasswordController, :edit
    put "/users/reset_password/:token", UserResetPasswordController, :update
  end

  scope "/", MyhpWeb do
    pipe_through [:browser, :require_authenticated_user]

    get "/users/settings", UserSettingsController, :edit
    put "/users/settings", UserSettingsController, :update
    get "/users/settings/confirm_email/:token", UserSettingsController, :confirm_email

    # Admin dashboard
    get "/admin", AdminController, :index

    # Admin user management actions
    post "/admin/users/:id/toggle_admin", AdminController, :toggle_admin
    post "/admin/users/:id/ban", AdminController, :ban_user
    post "/admin/users/:id/unban", AdminController, :unban_user
    delete "/admin/users/:id", AdminController, :delete_user
  end

  scope "/", MyhpWeb do
    pipe_through [:browser]

    delete "/users/log_out", UserSessionController, :delete
    get "/users/confirm", UserConfirmationController, :new
    post "/users/confirm", UserConfirmationController, :create
    get "/users/confirm/:token", UserConfirmationController, :edit
    post "/users/confirm/:token", UserConfirmationController, :update
  end
end
