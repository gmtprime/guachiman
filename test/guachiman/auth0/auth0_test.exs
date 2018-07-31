defmodule Guachiman.Auth0.Auth0Test do
  use ExUnit.Case, async: true

  alias Guachiman.Auth0

  describe "update_file/1" do
    test "Updates key in the given :ets table" do
      table = :ets.new(:test_table, [:set, :public, read_concurrency: true])
      assert :ok = Auth0.update_file(table)

      assert [{:key, contents}] = :ets.lookup(table, :key)
      assert is_map(contents)
    end
  end

  describe "fetch/1" do
    test "Updates key when it doesn't exist" do
      table = :ets.new(:test_table, [:set, :public, read_concurrency: true])
      contents = Auth0.fetch(table)

      assert is_map(contents)
    end

    test "Retrieves the key when is already downloaded" do
      table = :ets.new(:test_table, [:set, :public, read_concurrency: true])
      assert :ok = Auth0.update_file(table)

      contents = Auth0.fetch(table)
      assert is_map(contents)
    end
  end
end
