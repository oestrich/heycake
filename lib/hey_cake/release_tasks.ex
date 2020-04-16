# Loosely from https://github.com/bitwalker/distillery/blob/master/docs/Running%20Migrations.md
defmodule HeyCake.ReleaseTasks do
  @moduledoc false

  @start_apps [
    :crypto,
    :ssl,
    :postgrex,
    :ecto,
    :ecto_sql
  ]

  @repos [
    HeyCake.Repo
  ]

  def startup() do
    IO.puts("Loading hey_cake...")

    # Load the code for hey_cake, but don't start it
    Application.load(:hey_cake)

    IO.puts("Starting dependencies..")
    # Start apps necessary for executing migrations
    Enum.each(@start_apps, &Application.ensure_all_started/1)

    # Start the Repo(s) for hey_cake
    IO.puts("Starting repos..")
    Enum.each(@repos, & &1.start_link(pool_size: 2))
  end
end

defmodule HeyCake.ReleaseTasks.Migrate do
  @moduledoc """
  Migrate the database
  """

  alias HeyCake.ReleaseTasks
  alias HeyCake.Repo

  @apps [
    :hey_cake
  ]

  @doc """
  Migrate the database
  """
  def run() do
    ReleaseTasks.startup()
    Enum.each(@apps, &run_migrations_for/1)
    IO.puts("Success!")
  end

  def priv_dir(app), do: "#{:code.priv_dir(app)}"

  defp run_migrations_for(app) do
    IO.puts("Running migrations for #{app}")
    Ecto.Migrator.run(Repo, migrations_path(app), :up, all: true)
  end

  defp migrations_path(app), do: Path.join([priv_dir(app), "repo", "migrations"])
end
