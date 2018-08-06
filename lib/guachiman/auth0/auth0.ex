defmodule Guachiman.Auth0 do
  @moduledoc """
  Wraps AuthEx to request 1Bitcloud's Auth0 account.
  """
  use GenServer

  alias Guachiman.Settings

  require Logger

  @table_name :jwks_json
  @table_options [:set, :public, :named_table, read_concurrency: true]

  ############
  # Public API

  @doc """
  Starts an AuthEx wrapper process with some optional `GenServer` `options`.
  """
  @spec start_link() :: GenServer.on_start()
  @spec start_link(GenServer.options()) :: GenServer.on_start()
  def start_link(options \\ [])

  def start_link(options) do
    GenServer.start_link(__MODULE__, nil, options)
  end

  @doc """
  Fetches the cache key.
  """
  @spec fetch() :: nil | term()
  @spec fetch(reference() | atom()) :: nil | term()
  def fetch(table_name \\ @table_name)

  def fetch(table_name) do
    with [] <- :ets.lookup(table_name, :key),
         :ok <- update_file(table_name) do
      fetch(table_name)
    else
      [{:key, key} | _] ->
        key

      _ ->
        nil
    end
  end

  ###########
  # Callbacks

  @doc false
  def init(_) do
    :ets.new(@table_name, @table_options)
    {:ok, nil, 0}
  end

  @doc false
  def handle_info(:timeout, _state) do
    timeout = Settings.guachiman_update_timeout()
    update_file(@table_name)
    {:noreply, nil, timeout}
  end

  #########
  # Helpers

  @doc false
  def update_file(table_name) do
    endpoint = Settings.guachiman_endpoint()

    with {:ok, %Tesla.Env{status: 200, body: body}} <- Tesla.get(endpoint),
         {:ok, decoded} <- Poison.decode(body),
         key = decoded |> Map.get("keys", []) |> List.first(),
         true <- :ets.insert(table_name, {:key, key}) do
      :ok
    else
      {:error, reason} = error ->
        Logger.error(fn ->
          "Cannot update Auth0 key file due to #{inspect(reason)}"
        end)

        error
    end
  end
end
