defmodule HeyCake.Repo do
  use Ecto.Repo,
    otp_app: :hey_cake,
    adapter: Ecto.Adapters.Postgres

  alias HeyCake.Config

  def init(_type, config) do
    vapor_config = Config.database()

    config =
      Keyword.merge(config,
        url: vapor_config.database_url,
        pool_size: vapor_config.pool_size
      )

    {:ok, config}
  end
end
