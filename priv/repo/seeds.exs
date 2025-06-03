# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Myhp.Repo.insert!(%Myhp.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias Myhp.Repo
alias Myhp.Accounts.User
alias Myhp.Blog.Post
alias Myhp.Chat.Message

# Create admin user
admin_user = %User{
  email: "mark.cotner@gmail.com",
  hashed_password: Bcrypt.hash_pwd_salt("b4sk3tb4ll 15 4 fun sp0rt"),
  confirmed_at: DateTime.utc_now() |> DateTime.truncate(:second)
}

admin =
  case Repo.get_by(User, email: "mark.cotner@gmail.com") do
    nil -> Repo.insert!(admin_user)
    user -> user
  end

# Create sample users for chat
demo_users = [
  %{email: "john.dev@example.com", name: "John Developer"},
  %{email: "sarah.coder@example.com", name: "Sarah Coder"},
  %{email: "mike.tech@example.com", name: "Mike Tech"}
]

created_users =
  Enum.map(demo_users, fn user_data ->
    case Repo.get_by(User, email: user_data.email) do
      nil ->
        %User{
          email: user_data.email,
          hashed_password: Bcrypt.hash_pwd_salt("password123"),
          confirmed_at: DateTime.utc_now() |> DateTime.truncate(:second)
        }
        |> Repo.insert!()

      user ->
        user
    end
  end)

# Create sample blog posts
sample_posts = [
  %{
    title: "Welcome to My Personal Homepage",
    content: """
    Welcome to my corner of the internet! I'm excited to share my thoughts, experiences, and knowledge with you through this platform.

    This site features:
    - A blog where I'll share technical insights and personal reflections
    - A chat system for real-time discussions with fellow developers
    - A portfolio showcasing my work and projects

    Feel free to explore, and don't hesitate to engage in the comments or join the chat!
    """,
    slug: "welcome-to-my-homepage",
    published: true,
    published_at:
      DateTime.add(DateTime.utc_now(), -7, :day)
      |> DateTime.to_naive()
      |> NaiveDateTime.truncate(:second)
  },
  %{
    title: "Building Real-Time Applications with Phoenix LiveView",
    content: """
    Phoenix LiveView has revolutionized how we build interactive web applications in Elixir. In this post, I'll share some insights from building this very chat system.

    Key benefits of LiveView:
    1. Real-time updates without complex JavaScript
    2. Server-rendered HTML with minimal client-side code
    3. Excellent development experience

    The chat system you see here demonstrates Phoenix PubSub in action, allowing multiple users to communicate in real-time with minimal complexity.
    """,
    slug: "phoenix-liveview-real-time",
    published: true,
    published_at:
      DateTime.add(DateTime.utc_now(), -3, :day)
      |> DateTime.to_naive()
      |> NaiveDateTime.truncate(:second)
  },
  %{
    title: "The Future of Web Development",
    content: """
    As we look ahead, several trends are shaping the future of web development:

    - **Real-time experiences**: Users expect instant updates and interactions
    - **Full-stack frameworks**: Tools like Phoenix LiveView, SvelteKit, and Next.js
    - **Edge computing**: Bringing computation closer to users
    - **WebAssembly**: Running high-performance code in browsers

    What excites you most about the future of web development? Join the chat to discuss!
    """,
    slug: "future-of-web-development",
    published: true,
    published_at:
      DateTime.add(DateTime.utc_now(), -1, :day)
      |> DateTime.to_naive()
      |> NaiveDateTime.truncate(:second)
  }
]

_created_posts =
  Enum.map(sample_posts, fn post_data ->
    case Repo.get_by(Post, slug: post_data.slug) do
      nil -> Repo.insert!(struct(Post, post_data))
      post -> post
    end
  end)

# Create sample portfolio projects
alias Myhp.Portfolio.Project

sample_projects = [
  %{
    title: "Personal Homepage & Community Platform",
    description:
      "A modern, feature-rich personal homepage built with Phoenix LiveView, featuring authentication, blogging, real-time chat, and community features. Demonstrates advanced LiveView patterns, real-time communication, and modern web design principles.",
    technologies: "Elixir, Phoenix LiveView, Tailwind CSS, SQLite, Alpine.js, Phoenix PubSub",
    github_url: "https://github.com/markcotner/myhp",
    live_url: "https://markcotner.com",
    image_url: "https://via.placeholder.com/800x600/3B82F6/FFFFFF?text=Personal+Homepage",
    featured: true,
    published: true
  },
  %{
    title: "Real-Time Chat Application",
    description:
      "A scalable real-time chat application showcasing Phoenix PubSub capabilities. Features include user presence, typing indicators, message persistence, and responsive design. Built to handle thousands of concurrent users with minimal latency.",
    technologies: "Elixir, Phoenix, LiveView, WebSockets, PostgreSQL, Redis",
    github_url: "https://github.com/markcotner/phoenix-chat",
    live_url: "https://chat-demo.markcotner.com",
    image_url: "https://via.placeholder.com/800x600/10B981/FFFFFF?text=Chat+App",
    featured: true,
    published: true
  },
  %{
    title: "E-Commerce Platform",
    description:
      "Full-featured e-commerce platform with inventory management, payment processing, and order tracking. Implements advanced search, filtering, and recommendation algorithms. Features admin dashboard and customer portal.",
    technologies: "React, Node.js, Express, MongoDB, Stripe API, JWT, Material-UI",
    github_url: "https://github.com/markcotner/ecommerce-platform",
    live_url: "https://shop-demo.markcotner.com",
    image_url: "https://via.placeholder.com/800x600/8B5CF6/FFFFFF?text=E-Commerce",
    featured: false,
    published: true
  },
  %{
    title: "Data Analytics Dashboard",
    description:
      "Interactive dashboard for business intelligence and data visualization. Processes large datasets with real-time updates, custom chart generation, and automated reporting. Integrates with multiple data sources and APIs.",
    technologies: "Python, Django, PostgreSQL, D3.js, Celery, Redis, Docker",
    github_url: "https://github.com/markcotner/analytics-dashboard",
    live_url: "https://analytics.markcotner.com",
    image_url: "https://via.placeholder.com/800x600/F59E0B/FFFFFF?text=Analytics",
    featured: false,
    published: true
  },
  %{
    title: "Mobile Task Manager",
    description:
      "Cross-platform mobile application for task and project management. Features offline synchronization, collaborative workspaces, and intelligent notifications. Built with modern mobile development best practices.",
    technologies: "React Native, Expo, Firebase, AsyncStorage, Push Notifications",
    github_url: "https://github.com/markcotner/task-manager-mobile",
    live_url: "",
    image_url: "https://via.placeholder.com/800x600/EF4444/FFFFFF?text=Task+Manager",
    featured: false,
    published: true
  },
  %{
    title: "API Gateway & Microservices",
    description:
      "Scalable microservices architecture with API gateway, service discovery, and distributed tracing. Demonstrates enterprise-level patterns for building resilient, maintainable systems at scale.",
    technologies: "Go, Docker, Kubernetes, gRPC, Consul, Prometheus, Grafana",
    github_url: "https://github.com/markcotner/microservices-gateway",
    live_url: "",
    image_url: "https://via.placeholder.com/800x600/6366F1/FFFFFF?text=Microservices",
    featured: false,
    published: true
  }
]

Enum.each(sample_projects, fn project_data ->
  case Repo.get_by(Project, title: project_data.title) do
    nil -> Repo.insert!(struct(Project, project_data))
    _project -> :ok
  end
end)

IO.puts("🌱 Database seeded successfully!")
IO.puts("📧 Admin login: mark.cotner@gmail.com / b4sk3tb4ll 15 4 fun sp0rt")

IO.puts(
  "👥 Demo users: john.dev@example.com, sarah.coder@example.com, mike.tech@example.com / password123"
)

IO.puts("🚀 Sample projects added to portfolio")
