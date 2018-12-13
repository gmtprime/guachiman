defmodule Guachiman.Plug.EnsureAuthenticated do
  @moduledoc """
  Automatically extracts audience provided by Guachiman's pipeline
  and passes it to Guardian.Plug.EnsureAuthenticated as a claim.
  """

  alias Guachiman.Plug.Pipeline
  alias Guardian.Plug.EnsureAuthenticated, as: GEnsureAuthenticated

  def init(opts), do: opts

  def call(conn, opts) do
    audience = Pipeline.fetch_audience(conn)

    claims =
      Keyword.get(opts, :claims, %{})
      |> Map.merge(%{"aud" => audience})

    options =
      GEnsureAuthenticated.init([])
      |> Keyword.put(:claims, claims)
      |> GEnsureAuthenticated.init()

    GEnsureAuthenticated.call(conn, options)
  end
end
