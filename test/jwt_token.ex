defmodule Guachiman.JWTTestHelper do
  @moduledoc """
  Issue and validate JWT token for testing.

  We'd use this to mock AUTH0 access tokens on unit tests.

  Currently tokens are generate through ExBitcloudApi's Guardian.
  """

  #  @private_key_pem "test/jwt_keys/jwtRS256_key.pem"
  #  @public_key_pem "test/jwt_keys/jwtRS256_pub.pem"
  #
  #  @default_aud "1bitcloud_microservices_api"

  @public_key_pem Application.get_env(:guachiman, :public_key)
  @private_key_pem Application.get_env(:guachiman, :private_key)

  @default_aud Application.get_env(:guachiman, :audience)

  @doc """
  Create a new token for the given resource's id, i.e,
  the JWT's `sub` claim.
  """
  @spec create_token(binary(), map()) ::
          {:ok, Guardian.Token.token(), Guardian.Token.claims()}
          | {:error, any()}
  def create_token(resource_id, claims \\ %{}) do
    secret = JOSE.JWK.from_pem_file(@private_key_pem)

    claims =
      if Map.has_key?(claims, "aud"), do: claims, else: Map.put(claims, "aud", @default_aud)

    opts = [allowed_algos: ["RS256"], secret: secret]
    Guachiman.Guardian.encode_and_sign(%{id: resource_id}, claims, opts)
  end

  @doc """
  Retrieve the testing public key from the pem file
  """
  def fetch_public_key() do
    JOSE.JWK.from_pem_file(@public_key_pem)
  end
end
