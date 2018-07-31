defmodule Guachiman.MixProject do
  use Mix.Project

  @version "0.1.0"

  def project do
    [
      app: :guachiman,
      version: @version,
      elixir: "~> 1.4",
      elixirc_paths: elixirc_paths(Mix.env),
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      mod: {Guachiman.Application, []},
      extra_applications: [:logger, :ex_bitcloud_db]
    ]
  end

  defp elixirc_paths(:dev) do
    elixirc_paths(:test)
  end
  defp elixirc_paths(:test) do
    ["lib", "deps/ex_bitcloud_db/test/support",
     "deps/ex_bitcloud_db/test/factories"]
  end
  defp elixirc_paths(_) do
    ["lib"]
  end

  @db_branch System.get_env("EX_BITCLOUD_DB_BRANCH") || "v1.3.0"
  @db_repo "git@bitbucket.org:gmtprime/ex_bitcloud_db.git"

  defp deps do
    [
      {:guardian, "~> 1.0"},
      {:auth0_ex, "~> 0.2.0"},
      {:tesla, "~> 1.1"},
      {:jason, "~> 1.1"},
      {:skogsra, "~> 0.2"},
      {:hackney, "~> 1.6"},
      {:ex_bitcloud_db, git: @db_repo, tag: @db_branch},
      {:ex_machina, "~> 2.2", only: [:test, :dev]},
      {:faker, "~> 0.10", only: [:test, :dev]}
    ]
  end
end
