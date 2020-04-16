import Config

config :hey_cake, HeyCake.Repo, ssl: true

config :hey_cake, Web.Endpoint,
  cache_static_manifest: "priv/static/cache_manifest.json",
  server: true

config :hey_cake, HeyCake.Mailer, adapter: Bamboo.LocalAdapter

config :logger, level: :info

config :phoenix, :logger, false

config :stein_phoenix, :views, error_helpers: Web.ErrorHelpers
