defmodule Guachiman.Auth0.Sandbox.JWTTokenTest do
  use ExUnit.Case, async: true

  import Guachiman.Auth0.Sandbox.JWTToken

  describe "update_file/1" do
    test "Updates key in the given :ets table" do
      table = :ets.new(:test_table, [:set, :public, read_concurrency: true])
      assert :ok = update_file(table)

      assert [{:key, contents}] = :ets.lookup(table, :key)
      assert is_map(contents)
    end
  end

  describe "create_token/1" do
    test "Creates a new token" do
      assert {:ok, token, claims} = create_token("some_id")
      assert is_binary(token)
      assert %{"sub" => "some_id"} = claims
    end

    test "Build token, add claims and create token" do
      audience = "my_auth0_audience"
      assert {:ok, _token, %{"aud" => ^audience}} = 
        build_token("my_resource_id")
        |> put_claim("aud", audience)
        |> create()
    end

    test "When not provide, the default audience is set as a claim" do
      audience = Application.get_env(:guachiman, :audience)
      assert {:ok, _token, %{"aud" => ^audience}} =
        create_token("resource_id")
    end
  end
end
