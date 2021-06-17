defmodule HeyCake.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  alias HeyCake.Config

  def start(_type, _args) do
    config = Config.application()

    Application.put_env(:ueberauth, Ueberauth.Strategy.Slack.OAuth,
      client_id: config.slack_client_id,
      client_secret: config.slack_client_secret
    )

    children = [
      HeyCake.Config.Cache,
      {Phoenix.PubSub, name: HeyCake.PubSub},
      HeyCake.Repo,
      {Oban, Config.oban_config()},
      HeyCake.Telemetry,
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
