defmodule Guachiman.Settings do
  @moduledoc """
  This module defines the available settings for Guachiman.
  """
  use Skogsra

  @doc """
  Guachiman update timeout.
  """
  app_env(:guachiman_update_timeout, :guachiman, :update_timeout, default: 300_000)

  @doc """
  Guachiman endpoint.
  """
  app_env(
    :guachiman_auth0_domain,
    :guachiman,
    :auth0_domain
  )

  @doc """
  Guachiman ets name
  """
  app_env(
    :guachiman_table_name,
    :guachiman,
    :table_name,
    default: :guachiman_jwks_json
  )
end
