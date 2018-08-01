use Mix.Config

config :logger, level: :warn

config :guachiman,
  resource: {Guachiman.Resource.Mock, :get, []}
