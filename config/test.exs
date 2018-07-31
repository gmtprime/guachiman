use Mix.Config

config :logger,
  level: :warn
config :ex_bitcloud_db, BitcloudDB.Repo,
  adapter: Ecto.Adapters.Postgres,
  pool: Ecto.Adapters.SQL.Sandbox
