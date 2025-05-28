defmodule MyhpWeb.ActivityLive do
  use MyhpWeb, :live_view

  alias Myhp.Blog
  alias Myhp.Chat
  alias Myhp.Portfolio
  alias Myhp.Repo

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      Phoenix.PubSub.subscribe(Myhp.PubSub, "activity_feed")
    end

    {:ok,
     socket
     |> assign(:page_title, "Activity Feed")
     |> load_activities()}
  end

  @impl true
  def handle_info({:new_activity, _activity}, socket) do
    {:noreply, load_activities(socket)}
  end

  defp load_activities(socket) do
    activities = get_recent_activities()
    assign(socket, :activities, activities)
  end

  defp get_recent_activities do
    # Get recent blog posts
    recent_posts =
      Blog.list_published_posts()
      |> Enum.take(10)
      |> Enum.map(&format_activity(&1, :blog_post))

    # Get recent comments  
    recent_comments =
      Blog.list_comments()
      |> Enum.take(10)
      |> Repo.preload([:user, :post])
      |> Enum.map(&format_activity(&1, :comment))

    # Get recent chat messages
    recent_messages =
      Chat.list_recent_messages_for_activity(10)
      |> Repo.preload([:user])
      |> Enum.map(&format_activity(&1, :chat_message))

    # Get recent projects
    recent_projects =
      Portfolio.list_published_projects()
      |> Enum.take(5)
      |> Enum.map(&format_activity(&1, :project))

    # Combine and sort by timestamp
    (recent_posts ++ recent_comments ++ recent_messages ++ recent_projects)
    |> Enum.sort_by(fn activity -> 
      case activity.timestamp do
        %DateTime{} = dt -> dt
        %NaiveDateTime{} = ndt -> DateTime.from_naive!(ndt, "Etc/UTC")
        nil -> DateTime.utc_now()
      end
    end, {:desc, DateTime})
    |> Enum.take(20)
  end

  defp format_activity(item, type) do
    case type do
      :blog_post ->
        %{
          id: "post_#{item.id}",
          type: :blog_post,
          title: item.title,
          description: String.slice(item.content || "", 0, 100) <> "...",
          url: ~p"/blog/#{item}",
          timestamp: item.published_at || item.inserted_at,
          user: nil,
          icon: "hero-document-text"
        }

      :comment ->
        %{
          id: "comment_#{item.id}",
          type: :comment,
          title: "New comment on \"#{item.post.title}\"",
          description: String.slice(item.content, 0, 100) <> "...",
          url: ~p"/blog/#{item.post}",
          timestamp: item.inserted_at,
          user: item.user,
          icon: "hero-chat-bubble-left"
        }

      :chat_message ->
        %{
          id: "message_#{item.id}",
          type: :chat_message,
          title: "#{item.user.email} sent a message",
          description: String.slice(item.content, 0, 100) <> "...",
          url: ~p"/chat",
          timestamp: item.inserted_at,
          user: item.user,
          icon: "hero-chat-bubble-oval-left"
        }

      :project ->
        %{
          id: "project_#{item.id}",
          type: :project,
          title: "New project: #{item.title}",
          description: item.description,
          url: ~p"/portfolio/#{item}",
          timestamp: item.inserted_at,
          user: nil,
          icon: "hero-code-bracket"
        }
    end
  end

  # Helper function to broadcast new activities
  def broadcast_activity(activity_type, item) do
    activity = format_activity(item, activity_type)
    Phoenix.PubSub.broadcast(Myhp.PubSub, "activity_feed", {:new_activity, activity})
  end

  defp time_ago(datetime) do
    now = DateTime.utc_now()
    
    # Convert to DateTime if needed
    dt = case datetime do
      %DateTime{} = dt -> dt
      %NaiveDateTime{} = ndt -> DateTime.from_naive!(ndt, "Etc/UTC")
      nil -> now
    end
    
    diff = DateTime.diff(now, dt, :second)

    cond do
      diff < 60 -> "#{diff}s ago"
      diff < 3600 -> "#{div(diff, 60)}m ago"
      diff < 86400 -> "#{div(diff, 3600)}h ago"
      diff < 604_800 -> "#{div(diff, 86400)}d ago"
      true -> Calendar.strftime(dt, "%b %d, %Y")
    end
  end

  defp activity_type_label(type) do
    case type do
      :blog_post -> "Blog Post"
      :comment -> "Comment"
      :chat_message -> "Chat"
      :project -> "Project"
    end
  end

  defp activity_badge_class(type) do
    case type do
      :blog_post -> "bg-blue-100 text-blue-800 dark:bg-blue-900/30 dark:text-blue-300"
      :comment -> "bg-green-100 text-green-800 dark:bg-green-900/30 dark:text-green-300"
      :chat_message -> "bg-purple-100 text-purple-800 dark:bg-purple-900/30 dark:text-purple-300"
      :project -> "bg-yellow-100 text-yellow-800 dark:bg-yellow-900/30 dark:text-yellow-300"
    end
  end

  defp action_label(type) do
    case type do
      :blog_post -> "Read"
      :comment -> "View Post"
      :chat_message -> "Join Chat"
      :project -> "View Project"
    end
  end
end
