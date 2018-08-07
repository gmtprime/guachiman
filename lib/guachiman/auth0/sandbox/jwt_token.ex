defmodule Guachiman.Auth0.Sandbox.JWTToken do
  @moduledoc """
  JWT token sandbox to use in tests.

  In your `config/test.exs` file add the following:

  ```
  config :guachiman,
    update_module: Guachiman.Sandbox.JWTToken,
    audience: "some_audience"
  ```

  and then in your tests request a valid token using the function
  `create_token/1` (without claims) or `create_token/2` (with claims) e.g:

  ```
  alias Guachiman.Sandbox.JWTToken

  (...)

  test "some test" do
    {:ok, token, claims} =
      JWTToken.create_token("some_resource_id", some_optional_claims)
    (...)
  end
  ```
  """

  @doc """
  Fetches the public key from the `"priv/jwt_keys"` folder.
  """
  @spec fetch_public_key() :: struct()
  def fetch_public_key do
    filename = "#{:code.priv_dir(:guachiman)}/jwt_keys/jwtRS256_pub.pem"
    JOSE.JWK.from_pem_file(filename)
  end

  @doc """
  Fetches the private key from the `"priv/jwt_keys"` folder.
  """
  @spec fetch_private_key() :: struct()
  def fetch_private_key do
    filename = "#{:code.priv_dir(:guachiman)}/jwt_keys/jwtRS256_key.pem"
    JOSE.JWK.from_pem_file(filename)
  end

  @doc """
  Fetches the audience from the configuration.
  """
  @spec fetch_audience() :: binary() | list(binary())
  def fetch_audience do
    Application.get_env(:guachiman, :audience, [])
  end

  @doc """
  Creates a new token for the given `resource_id` with some optional `claims`
  as the JWT's `"sub"` claim.
  """
  @spec create_token(binary(), map()) ::
          {:ok, Guardian.Token.token(), Guardian.Token.claims()}
          | {:error, any()}
  def create_token(resource_id, claims \\ %{}) do
    new_claims = Map.put_new(claims, "aud", fetch_audience())
    options = [allowed_algos: ["RS256"], secret: fetch_private_key()]
    Guachiman.Guardian.encode_and_sign(%{id: resource_id}, new_claims, options)
  end

  @doc """
  Updates file in the specified `table_name`.
  """
  @spec update_file(reference() | atom()) :: :ok | {:error, term()}
  def update_file(table_name) do
    with true <- :ets.insert(table_name, {:key, fetch_public_key()}) do
      :ok
    else
      _ ->
        {:error, "Cannot update key"}
    end
  end
end
