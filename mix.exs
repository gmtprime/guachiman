defmodule Guachiman.MixProject do
  use Mix.Project

  @version "0.1.0"

  def project do
    [
      app: :guachiman,
      version: @version,
      elixir: "~> 1.6",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      mod: {Guachiman.Application, []},
      extra_applications: [:logger]
    ]
  end

  defp elixirc_paths(:dev) do
    elixirc_paths(:test)
  end

  defp elixirc_paths(:test) do
    [
      "lib"
    ]
  end

  defp elixirc_paths(_) do
    ["lib"]
  end

  defp deps do
    [
      {:cowboy, "~> 2.0", only: [:test, :dev]},
      {:plug, "~> 1.0"},
      {:guardian, "~> 1.0"},
      {:tesla, "~> 1.1"},
      {:skogsra, "~> 0.2"},
      {:hackney, "~> 1.6"},
      {:mox, "~> 0.3", only: [:test]}
    ]
  end
end
