use Mix.Config

config :logger, level: :warn

config :tesla, adapter: Tesla.Mock

config :guachiman,
  auth0_domain: "guachiman_example",
  resource: {Guachiman.Resource.Mock, :get, []},
  update_module: Guachiman.Auth0.Sandbox.JWTToken
