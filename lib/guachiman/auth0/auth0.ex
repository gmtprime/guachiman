defmodule Guachiman.Auth0 do
  @moduledoc """
  Fetch JWKS.json file from Auth0 given an auth0_domain.
  """
  use GenServer

  alias Guachiman.Settings

  require Logger

  @table_name Settings.guachiman_table_name()
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
    update_module = Settings.guachiman_update_module()

    with [] <- :ets.lookup(table_name, :key),
         :ok <- apply(update_module, :update_file, [table_name]) do
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
    update_module = Settings.guachiman_update_module()
    timeout = Settings.guachiman_update_timeout()
    apply(update_module, :update_file, [@table_name])
    {:noreply, nil, timeout}
  end

  #########
  # Helpers

  @doc false
  def update_file(table_name) do
    auth0_domain = Settings.guachiman_auth0_domain()

    unless auth0_domain, do: raise("Missing guachiman_auth0_domain config attribute")

    with {:ok, %Tesla.Env{status: 200, body: body}} <-
           Tesla.get("https://#{auth0_domain}/.well-known/jwks.json"),
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
