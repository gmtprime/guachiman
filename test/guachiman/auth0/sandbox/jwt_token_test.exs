defmodule Guachiman.Auth0.Sandbox.JWTTokenTest do
  use ExUnit.Case, async: true

  alias Guachiman.Auth0.Sandbox.JWTToken, as: Sandbox

  describe "update_file/1" do
    test "Updates key in the given :ets table" do
      table = :ets.new(:test_table, [:set, :public, read_concurrency: true])
      assert :ok = Sandbox.update_file(table)

      assert [{:key, contents}] = :ets.lookup(table, :key)
      assert is_map(contents)
    end
  end

  describe "create_token/1" do
    test "Creates a new token" do
      assert {:ok, token, claims} = Sandbox.create_token("some_id")
      assert is_binary(token)
      assert %{"sub" => "some_id"} = claims
    end
  end
end
