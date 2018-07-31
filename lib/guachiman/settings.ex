defmodule Guachiman.Settings do
  @moduledoc """
  This module defines the available settings for Guachiman.
  """
  use Skogsra

  @doc """
  Guachiman update timeout.
  """
  app_env :guachiman_update_timeout, :guachiman, :update_timeout,
    default: 300_000

  @doc """
  Guachiman endpoint.
  """
  app_env :guachiman_endpoint, :guachiman, :endpoint,
    default: "https://1bitcloud.auth0.com/.well-known/jwks.json"
end
