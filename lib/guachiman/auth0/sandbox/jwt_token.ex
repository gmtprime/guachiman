defmodule Guachiman.Auth0.Sandbox.JWTToken do
  @moduledoc """
  JWT token sandbox to use in tests.

  In your `config/test.exs` file add the following:

  ```
  config :guachiman,
    update_module: Guachiman.Auth0.Sandbox.JWTToken,
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

  ### Build token on different steps

  You can build a %JWTToken{} struct using `build_token/2`, and then add
  claims with `add_claim/3`.

  ```
  test "building token step by step" do
    {:ok, token, claims} = build_token("some_resource_id")
    |> add_claim("aud", "my_auth0_audience_api")
    |> create()

    assert claims["aud"] == "my_auth0_audience_api"
  end

  ```


  """
  @enforce_keys [:resource_id]
  defstruct [:resource_id, claims: %{}, algo: "RS256", secret: nil]
  @type t :: %__MODULE__{resource_id: binary(), claims: map(), algo: binary()}

  ### PUBLIC API

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
    Application.get_env(:guachiman, :audience, nil)
  end

  @doc """
  Creates a new token for the given `resource_id` with some optional `claims`
  as the JWT's `"sub"` claim.
  """
  @spec create_token(binary(), map()) ::
          {:ok, Guardian.Token.token(), Guardian.Token.claims()}
          | {:error, any()}
  def create_token(resource_id, claims \\ %{}) do
    #    new_claims = Map.put_new(claims, "aud", fetch_audience())
    #    options = [allowed_algos: ["RS256"], secret: fetch_private_key()]
    #    Guachiman.Guardian.encode_and_sign(%{id: resource_id}, new_claims, options)

    build_token(resource_id, claims)
    |> create()
  end

  @doc """
  Build a new JWTToken struct with the given resource id
  and claims.
  """
  @spec build_token(binary(), map()) :: __MODULE__.t()
  def build_token(resource_id, claims \\ %{}) do
    %__MODULE__{resource_id: resource_id, claims: claims}
  end

  @doc """
  Puts a claim to the given JWTToken struct
  """
  @spec put_claim(__MODULE__.t(), atom(), any()) :: __MODULE__.t()
  def put_claim(%__MODULE__{claims: claims} = token, key, value) do
    new_claims = Map.put(claims, key, value)

    %{token | claims: new_claims}
  end

  @doc """
  Defines the secret to encode and sign this token.
  """
  @spec put_secret(__MODULE__.t(), term()) :: __MODULE__.t()
  def put_secret(%__MODULE__{secret: nil} = token, secret: secret),
    do: token |> Map.put(:secret, secret)

  @doc """
  Puts token signing algorithm.
  """
  @spec put_algorithm(__MODULE__.t(), term()) :: __MODULE__.t()
  def put_algorithm(token, algo) do
    token
    |> Map.put(:algo, algo)
  end

  @doc """
  Encodes and signs a new token using `Guachiman.Guardian.encode_and_sign`
  given a `JWTToken` struct.
  """
  @spec create(__MODULE__.t()) ::
          {:ok, Guardian.Token.token(), Guardian.Token.claims()}
          | {:error, term()}
  def create(token) do
    %__MODULE__{resource_id: id, claims: claims, algo: algo, secret: secret} =
      token
      |> check_claims
      |> check_secret

    # Guardian expects a list as allowed_algos
    options = [allowed_algos: [algo], secret: secret]
    Guachiman.Guardian.encode_and_sign(%{id: id}, claims, options)
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

  ### HELPERS

  # when secret is not set, use `fetch_private_key`
  defp check_secret(%__MODULE__{secret: nil} = token),
    do: token |> Map.put(:secret, fetch_private_key())

  defp check_secret(token), do: token

  # check for default claims
  defp check_claims(%__MODULE__{claims: claims} = token) do
    # add `aud` when it hasn't been set
    new_claims = Map.put_new(claims, "aud", fetch_audience())

    token
    |> Map.put(:claims, new_claims)
  end
end
