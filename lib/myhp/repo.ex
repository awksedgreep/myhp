defmodule Myhp.Repo do
  use Ecto.Repo,
    otp_app: :myhp,
    adapter: Ecto.Adapters.SQLite3

  use Scrivener, page_size: 10
end
