defmodule Myhp.ContactFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Myhp.Contact` context.
  """

  @doc """
  Generate a contact_message.
  """
  def contact_message_fixture(attrs \\ %{}) do
    {:ok, contact_message} =
      attrs
      |> Enum.into(%{
        email: "test@example.com",
        message: "some message",
        name: "some name",
        read: true,
        subject: "some subject"
      })
      |> Myhp.Contact.create_contact_message()

    contact_message
  end
end
