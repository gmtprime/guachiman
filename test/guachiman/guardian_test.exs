defmodule Guachiman.GuardianTest do
  use ExUnit.Case, async: false

  alias Guachiman.Guardian, as: GGuardian

  import Mox

  setup do
    :ok
  end

  describe "subject_for_token/2" do
    test "Returns ID when the resources has it" do
      assert {:ok, "42"} = GGuardian.subject_for_token(%{id: 42}, :whatever)
    end

    test "Returns error when the resource doesn't have an ID" do
      assert {:error, _} = GGuardian.subject_for_token(nil, :whatever)
    end
  end

  describe "resource_from_claims/1" do
    test "gets resource" do
      id = "randomclient@clients"

      Guachiman.Resource.Mock
      |> expect(:get, fn ^id -> {:ok, id} end)

      assert {:ok, ^id} = GGuardian.resource_from_claims(%{"sub" => id})
    end

    test "returns error while retrieving the resource" do
      Guachiman.Resource.Mock
      |> expect(:get, fn _ -> {:error, :invalid_subject} end)

      assert {:error, :invalid_subject} =
               GGuardian.resource_from_claims(%{"sub" => "somesubject"})
    end

    test "given resource function return unexpected value" do
      Guachiman.Resource.Mock
      |> expect(:get, fn _ -> nil end)

      assert {:error, "Invalid resource"} = GGuardian.resource_from_claims(%{"sub" => "whatever"})
    end
  end
end
