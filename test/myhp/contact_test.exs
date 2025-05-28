defmodule Myhp.ContactTest do
  use Myhp.DataCase

  alias Myhp.Contact

  describe "contact_messages" do
    alias Myhp.Contact.ContactMessage

    import Myhp.ContactFixtures

    @invalid_attrs %{message: nil, name: nil, read: nil, email: nil, subject: nil}

    test "list_contact_messages/0 returns all contact_messages" do
      contact_message = contact_message_fixture()
      assert Contact.list_contact_messages() == [contact_message]
    end

    test "get_contact_message!/1 returns the contact_message with given id" do
      contact_message = contact_message_fixture()
      assert Contact.get_contact_message!(contact_message.id) == contact_message
    end

    test "create_contact_message/1 with valid data creates a contact_message" do
      valid_attrs = %{
        message: "some message",
        name: "some name",
        read: true,
        email: "test@example.com",
        subject: "some subject"
      }

      assert {:ok, %ContactMessage{} = contact_message} =
               Contact.create_contact_message(valid_attrs)

      assert contact_message.message == "some message"
      assert contact_message.name == "some name"
      assert contact_message.read == true
      assert contact_message.email == "test@example.com"
      assert contact_message.subject == "some subject"
    end

    test "create_contact_message/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Contact.create_contact_message(@invalid_attrs)
    end

    test "update_contact_message/2 with valid data updates the contact_message" do
      contact_message = contact_message_fixture()

      update_attrs = %{
        message: "some updated message",
        name: "some updated name",
        read: false,
        email: "updated@example.com",
        subject: "some updated subject"
      }

      assert {:ok, %ContactMessage{} = contact_message} =
               Contact.update_contact_message(contact_message, update_attrs)

      assert contact_message.message == "some updated message"
      assert contact_message.name == "some updated name"
      assert contact_message.read == false
      assert contact_message.email == "updated@example.com"
      assert contact_message.subject == "some updated subject"
    end

    test "update_contact_message/2 with invalid data returns error changeset" do
      contact_message = contact_message_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Contact.update_contact_message(contact_message, @invalid_attrs)

      assert contact_message == Contact.get_contact_message!(contact_message.id)
    end

    test "delete_contact_message/1 deletes the contact_message" do
      contact_message = contact_message_fixture()
      assert {:ok, %ContactMessage{}} = Contact.delete_contact_message(contact_message)
      assert_raise Ecto.NoResultsError, fn -> Contact.get_contact_message!(contact_message.id) end
    end

    test "change_contact_message/1 returns a contact_message changeset" do
      contact_message = contact_message_fixture()
      assert %Ecto.Changeset{} = Contact.change_contact_message(contact_message)
    end
  end
end
