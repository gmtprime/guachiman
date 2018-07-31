defmodule Guachiman.Application do
  @moduledoc """
  Guachiman application.
  """
  use Application

  def start(_type, _args) do
    import Supervisor.Spec

    children = [
      worker(Guachiman.Auth0, [[name: Guachiman.Auth0]])
    ]

    opts = [strategy: :one_for_one, name: Guachiman.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
