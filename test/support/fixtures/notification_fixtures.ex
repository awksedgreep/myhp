defmodule Myhp.NotificationFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Myhp.Notification` context.
  """

  @doc """
  Generate a notification.
  """
  def notification_fixture(attrs \\ %{}) do
    user = if attrs[:user_id], do: nil, else: Myhp.AccountsFixtures.user_fixture()
    
    # For testing purposes, create a simple map since we don't have the notification schema yet
    %{
      id: System.unique_integer([:positive]),
      user_id: user && user.id || attrs[:user_id],
      message: Map.get(attrs, :message, "Test notification"),
      read: Map.get(attrs, :read, false),
      inserted_at: DateTime.utc_now() |> DateTime.truncate(:second)
    }
  end
end