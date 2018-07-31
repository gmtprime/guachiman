defmodule Guachiman.GuardianTest do
  use ExUnit.Case, async: false

  alias Guachiman.Guardian, as: GGuardian

  import BitcloudDB.Factory

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(BitcloudDB.Repo)
  end

  describe "subject_for_token/2" do
    test "Returns ID when the resources has it" do
      assert {:ok, "42"} = GGuardian.subject_for_token(%{id: 42}, :whatever)
    end

    test "Returns error when the resource doesn't have an ID" do
      assert {:error, _} = GGuardian.subject_for_token(nil, :whatever)
    end
  end

  describe "resource_from_claims/2" do
    test "gets resource" do
      %{user_id: id} = insert(:auth_user)
      assert {:ok, %{user_id: ^id}} = GGuardian.resource_from_claims(%{"sub" => id})
    end
  end
end
