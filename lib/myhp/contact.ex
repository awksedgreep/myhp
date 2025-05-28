defmodule Myhp.Contact do
  @moduledoc """
  The Contact context.
  """

  import Ecto.Query, warn: false
  alias Myhp.Repo

  alias Myhp.Contact.ContactMessage

  @doc """
  Returns the list of contact_messages.

  ## Examples

      iex> list_contact_messages()
      [%ContactMessage{}, ...]

  """
  def list_contact_messages do
    ContactMessage
    |> order_by([c], desc: c.inserted_at)
    |> Repo.all()
  end

  @doc """
  Returns the list of unread contact messages.
  """
  def list_unread_contact_messages do
    ContactMessage
    |> where([c], c.read == false)
    |> order_by([c], desc: c.inserted_at)
    |> Repo.all()
  end

  @doc """
  Returns the count of unread contact messages.
  """
  def count_unread_contact_messages do
    ContactMessage
    |> where([c], c.read == false)
    |> Repo.aggregate(:count, :id)
  end

  @doc """
  Gets a single contact_message.

  Raises `Ecto.NoResultsError` if the Contact message does not exist.

  ## Examples

      iex> get_contact_message!(123)
      %ContactMessage{}

      iex> get_contact_message!(456)
      ** (Ecto.NoResultsError)

  """
  def get_contact_message!(id), do: Repo.get!(ContactMessage, id)

  @doc """
  Creates a contact_message.

  ## Examples

      iex> create_contact_message(%{field: value})
      {:ok, %ContactMessage{}}

      iex> create_contact_message(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_contact_message(attrs \\ %{}) do
    %ContactMessage{}
    |> ContactMessage.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a contact_message.

  ## Examples

      iex> update_contact_message(contact_message, %{field: new_value})
      {:ok, %ContactMessage{}}

      iex> update_contact_message(contact_message, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_contact_message(%ContactMessage{} = contact_message, attrs) do
    contact_message
    |> ContactMessage.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a contact_message.

  ## Examples

      iex> delete_contact_message(contact_message)
      {:ok, %ContactMessage{}}

      iex> delete_contact_message(contact_message)
      {:error, %Ecto.Changeset{}}

  """
  def delete_contact_message(%ContactMessage{} = contact_message) do
    Repo.delete(contact_message)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking contact_message changes.

  ## Examples

      iex> change_contact_message(contact_message)
      %Ecto.Changeset{data: %ContactMessage{}}

  """
  def change_contact_message(%ContactMessage{} = contact_message, attrs \\ %{}) do
    ContactMessage.changeset(contact_message, attrs)
  end

  @doc """
  Returns the count of contact messages.

  ## Examples

      iex> count_contact_messages()
      8

  """
  def count_contact_messages do
    Repo.aggregate(ContactMessage, :count, :id)
  end
end
