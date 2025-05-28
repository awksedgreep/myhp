defmodule Myhp.NotificationFixturesTest do
  use Myhp.DataCase

  alias Myhp.NotificationFixtures

  describe "notification_fixture/1" do
    test "creates a notification with default values" do
      notification = NotificationFixtures.notification_fixture()

      assert is_integer(notification.id)
      assert is_integer(notification.user_id)
      assert notification.message == "Test notification"
      assert notification.read == false
      assert %DateTime{} = notification.inserted_at
    end

    test "creates a notification with custom attributes" do
      user = Myhp.AccountsFixtures.user_fixture()
      attrs = %{
        user_id: user.id,
        message: "Custom notification message",
        read: true
      }

      notification = NotificationFixtures.notification_fixture(attrs)

      assert notification.user_id == user.id
      assert notification.message == "Custom notification message"
      assert notification.read == true
      assert %DateTime{} = notification.inserted_at
    end

    test "creates a user when user_id is not provided" do
      notification = NotificationFixtures.notification_fixture()

      assert is_integer(notification.user_id)
      assert notification.user_id > 0
    end

    test "uses provided user_id when given" do
      user = Myhp.AccountsFixtures.user_fixture()
      
      notification = NotificationFixtures.notification_fixture(%{user_id: user.id})

      assert notification.user_id == user.id
    end

    test "generates unique IDs for each notification" do
      notification1 = NotificationFixtures.notification_fixture()
      notification2 = NotificationFixtures.notification_fixture()

      assert notification1.id != notification2.id
    end
  end
end