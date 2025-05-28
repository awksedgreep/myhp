defmodule Myhp.Chat.Presence do
  @moduledoc """
  Simple presence tracking for chat users using ETS
  """
  @table_name :chat_presence

  def init do
    unless :ets.whereis(@table_name) != :undefined do
      :ets.new(@table_name, [:set, :public, :named_table])
    end
  end

  def join(user_email) do
    init()
    :ets.insert(@table_name, {user_email, true})
    list()
  end

  def leave(user_email) do
    init()
    :ets.delete(@table_name, user_email)
    list()
  end

  def list do
    init()
    case :ets.tab2list(@table_name) do
      list when is_list(list) -> Enum.map(list, fn {email, _} -> email end)
      _ -> []
    end
  end
end