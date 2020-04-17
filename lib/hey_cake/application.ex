defmodule HeyCake.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  alias HeyCake.Config

  def start(_type, _args) do
    config = Config.application()

    Application.put_env(:stein_storage, :bucket, config.stein_storage_bucket)

    children = [
      HeyCake.Config.Cache,
      HeyCake.Repo,
      Web.Endpoint
    ]

    opts = [strategy: :one_for_one, name: HeyCake.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    Web.Endpoint.config_change(changed, removed)
    :ok
  end
end
