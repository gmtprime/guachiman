use Mix.Config

config :ex_bitcloud_db,
ecto_repos: [BitcloudDB.Repo]

config :tesla,
  adapter: Tesla.Adapter.Hackney

import_config "#{Mix.env}.exs"
