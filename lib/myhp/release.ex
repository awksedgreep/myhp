defmodule Myhp.Release do
  @moduledoc """
  Release tasks for database migrations and seeding.
  """
  @app :myhp

  def migrate do
    load_app()

    for repo <- repos() do
      {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :up, all: true))
    end
  end

  def seed do
    load_app()

    # Start required applications for SQLite
    Application.ensure_all_started(:ecto_sqlite3)
    Application.ensure_all_started(:telemetry)

    # Run seeds using with_repo to handle connection lifecycle
    for repo <- repos() do
      {:ok, _, _} =
        Ecto.Migrator.with_repo(repo, fn _repo ->
          seed_script = priv_path_for(repo, "seeds.exs")

          if File.exists?(seed_script) do
            IO.puts("Running seed script...")
            Code.eval_file(seed_script)
          end
        end)
    end

    IO.puts("Seeding completed!")
  end

  defp repos do
    Application.fetch_env!(@app, :ecto_repos)
  end

  defp load_app do
    Application.load(@app)
  end

  defp priv_path_for(repo, filename) do
    app_dir = Application.app_dir(@app)
    repo_underscore = repo |> Module.split() |> List.last() |> Macro.underscore()
    Path.join([app_dir, "priv", repo_underscore, filename])
  end
end
