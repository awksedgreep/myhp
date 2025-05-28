defmodule MyhpWeb.Admin.AnalyticsLive do
  use MyhpWeb, :live_view

  alias Myhp.Blog
  alias Myhp.Chat
  alias Myhp.Portfolio
  alias Myhp.Accounts
  alias Myhp.Contact

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Analytics Dashboard")
     |> assign(:current_page, "admin")
     |> load_analytics()}
  end

  defp load_analytics(socket) do
    # Basic counts
    posts_count = Blog.count_posts()
    comments_count = Blog.count_comments()
    users_count = Accounts.count_users()
    projects_count = Portfolio.count_projects()
    messages_count = Chat.count_messages()
    contact_messages_count = Contact.count_contact_messages()

    # Engagement metrics
    posts_with_comments = get_posts_with_comments_count()

    avg_comments_per_post =
      if posts_count > 0, do: Float.round(comments_count / posts_count, 1), else: 0

    active_users_count = get_active_users_count()

    # Time-based analytics
    recent_activity = get_recent_activity_metrics()
    monthly_stats = get_monthly_stats()

    # Top content
    top_commented_posts = get_top_commented_posts(5)
    most_active_users = get_most_active_users(5)

    socket
    |> assign(:basic_stats, %{
      posts: posts_count,
      comments: comments_count,
      users: users_count,
      projects: projects_count,
      messages: messages_count,
      contact_messages: contact_messages_count
    })
    |> assign(:engagement_metrics, %{
      posts_with_comments: posts_with_comments,
      avg_comments_per_post: avg_comments_per_post,
      active_users: active_users_count,
      engagement_rate: calculate_engagement_rate(posts_with_comments, posts_count)
    })
    |> assign(:recent_activity, recent_activity)
    |> assign(:monthly_stats, monthly_stats)
    |> assign(:top_content, %{
      top_posts: top_commented_posts,
      active_users: most_active_users
    })
  end

  defp get_posts_with_comments_count do
    Blog.list_posts()
    |> Enum.count(fn post ->
      Blog.list_comments_for_post(post.id) |> length() > 0
    end)
  end

  defp get_active_users_count do
    # Users who have commented or sent messages in the last 30 days
    thirty_days_ago = DateTime.utc_now() |> DateTime.add(-30, :day)

    commented_users =
      Blog.list_comments()
      |> Enum.filter(fn comment ->
        DateTime.compare(comment.inserted_at, thirty_days_ago) == :gt
      end)
      |> Enum.map(& &1.user_id)
      |> Enum.uniq()

    messaged_users =
      Chat.list_recent_messages_for_activity(1000)
      |> Enum.filter(fn message ->
        DateTime.compare(message.inserted_at, thirty_days_ago) == :gt
      end)
      |> Enum.map(& &1.user_id)
      |> Enum.uniq()

    (commented_users ++ messaged_users) |> Enum.uniq() |> length()
  end

  defp calculate_engagement_rate(posts_with_comments, total_posts) do
    if total_posts > 0 do
      Float.round(posts_with_comments / total_posts * 100, 1)
    else
      0
    end
  end

  defp get_recent_activity_metrics do
    now = DateTime.utc_now()
    week_ago = DateTime.add(now, -7, :day)
    month_ago = DateTime.add(now, -30, :day)

    %{
      posts_this_week: count_items_since(Blog.list_posts(), week_ago),
      posts_this_month: count_items_since(Blog.list_posts(), month_ago),
      comments_this_week: count_items_since(Blog.list_comments(), week_ago),
      comments_this_month: count_items_since(Blog.list_comments(), month_ago),
      users_this_week: count_items_since(Accounts.list_users(), week_ago),
      users_this_month: count_items_since(Accounts.list_users(), month_ago)
    }
  end

  defp count_items_since(items, since_date) do
    Enum.count(items, fn item ->
      DateTime.compare(item.inserted_at, since_date) == :gt
    end)
  end

  defp get_monthly_stats do
    # Get stats for the last 6 months
    0..5
    |> Enum.map(fn i ->
      date = DateTime.utc_now() |> DateTime.add(-i * 30, :day)
      month_start = %{date | day: 1, hour: 0, minute: 0, second: 0}
      month_end = DateTime.add(month_start, 30, :day)

      posts = count_items_between(Blog.list_posts(), month_start, month_end)
      comments = count_items_between(Blog.list_comments(), month_start, month_end)
      users = count_items_between(Accounts.list_users(), month_start, month_end)

      %{
        month: Calendar.strftime(month_start, "%b %Y"),
        posts: posts,
        comments: comments,
        users: users
      }
    end)
    |> Enum.reverse()
  end

  defp count_items_between(items, start_date, end_date) do
    Enum.count(items, fn item ->
      DateTime.compare(item.inserted_at, start_date) != :lt and
        DateTime.compare(item.inserted_at, end_date) == :lt
    end)
  end

  defp get_top_commented_posts(limit) do
    Blog.list_posts()
    |> Enum.map(fn post ->
      comment_count = Blog.list_comments_for_post(post.id) |> length()
      %{post: post, comment_count: comment_count}
    end)
    |> Enum.sort_by(& &1.comment_count, :desc)
    |> Enum.take(limit)
  end

  defp get_most_active_users(limit) do
    users = Accounts.list_users()

    users
    |> Enum.map(fn user ->
      comment_count = Blog.list_comments() |> Enum.count(&(&1.user_id == user.id))

      message_count =
        Chat.list_recent_messages_for_activity(1000) |> Enum.count(&(&1.user_id == user.id))

      total_activity = comment_count + message_count

      %{
        user: user,
        comment_count: comment_count,
        message_count: message_count,
        total_activity: total_activity
      }
    end)
    |> Enum.filter(&(&1.total_activity > 0))
    |> Enum.sort_by(& &1.total_activity, :desc)
    |> Enum.take(limit)
  end
end
