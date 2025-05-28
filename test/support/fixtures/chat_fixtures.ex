defmodule Myhp.ChatFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Myhp.Chat` context.
  """

  @doc """
  Generate a message.
  """
  def message_fixture(attrs \\ %{}) do
    # Create a user if not provided
    user = if attrs[:user_id], do: nil, else: Myhp.AccountsFixtures.user_fixture()

    {:ok, message} =
      attrs
      |> Enum.into(%{
        content: "some content",
        user_id: user && user.id || attrs[:user_id]
      })
      |> Myhp.Chat.create_message()

    message
  end
end
