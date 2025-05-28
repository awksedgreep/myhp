defmodule Myhp.Chat.PresenceTest do
  use ExUnit.Case, async: false
  
  alias Myhp.Chat.Presence

  describe "presence tracking" do
    setup do
      # Clean up any existing ETS table before each test
      if :ets.whereis(:chat_presence) != :undefined do
        :ets.delete(:chat_presence)
      end
      :ok
    end

    test "starts with empty user list" do
      assert Presence.list() == []
    end

    test "can add a user" do
      users = Presence.join("user1@example.com")
      assert "user1@example.com" in users
      assert Presence.list() == ["user1@example.com"]
    end

    test "can add multiple users" do
      Presence.join("user1@example.com")
      Presence.join("user2@example.com")
      
      users = Presence.list()
      assert "user1@example.com" in users
      assert "user2@example.com" in users
      assert length(users) == 2
    end

    test "joining same user twice doesn't create duplicates" do
      Presence.join("user1@example.com")
      Presence.join("user1@example.com")
      
      users = Presence.list()
      assert users == ["user1@example.com"]
    end

    test "can remove a user" do
      Presence.join("user1@example.com")
      Presence.join("user2@example.com")
      
      remaining_users = Presence.leave("user1@example.com")
      assert "user1@example.com" not in remaining_users
      assert "user2@example.com" in remaining_users
      assert Presence.list() == ["user2@example.com"]
    end

    test "removing non-existent user doesn't crash" do
      Presence.join("user1@example.com")
      users = Presence.leave("nonexistent@example.com")
      
      assert users == ["user1@example.com"]
    end

    test "handles concurrent access" do
      # Initialize the presence table first
      Presence.join("init@example.com")
      Presence.leave("init@example.com")
      
      # Simulate multiple processes joining at once
      tasks = for i <- 1..10 do
        Task.async(fn -> 
          Presence.join("user#{i}@example.com")
        end)
      end
      
      # Wait for all tasks to complete
      Enum.each(tasks, &Task.await/1)
      
      users = Presence.list()
      assert length(users) == 10
      
      # Verify all users are present
      for i <- 1..10 do
        assert "user#{i}@example.com" in users
      end
    end
  end
end