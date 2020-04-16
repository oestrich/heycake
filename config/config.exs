# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :hey_cake,
  namespace: Web,
  ecto_repos: [HeyCake.Repo]

# Configures the endpoint
config :hey_cake, Web.Endpoint,
  render_errors: [view: Web.ErrorView, accepts: ~w(html json)],
  pubsub: [name: HeyCake.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :stein_phoenix, :views, error_helpers: Web.ErrorHelpers

if File.exists?("config/#{Mix.env()}.exs") do
  import_config "#{Mix.env()}.exs"
end
