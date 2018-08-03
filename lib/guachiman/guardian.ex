defmodule Guachiman.Guardian do
  @moduledoc """
  Guardian implementation for Token based authentication with AUTH0.
  """
  use Guardian, otp_app: :guachiman

  ###########
  # Callbacks

  @doc """
  Returns the subject given a `resource` and some unused `claims`.
  """
  @spec subject_for_token(term(), term()) :: {:ok, binary()} | {:error, term()}
  def subject_for_token(resource, claims)

  def subject_for_token(%{id: id}, _claims) do
    {:ok, to_string(id)}
  end

  def subject_for_token(_resource, _claims) do
    {:error, "Invalid subject"}
  end

  @doc """
  Gets the resource given some `claims`.
  """
  @spec resource_from_claims(map()) :: {:ok, term()} | {:error, term()}
  def resource_from_claims(claims)

  def resource_from_claims(%{"sub" => subject}) do
    if String.contains?(subject, "@clients") do
      {:ok, subject}
    else
      resolve_resource(subject)
    end
  end

  def resource_from_claims(_claims) do
    {:error, "Invalid subject"}
  end

  @doc """
  Validates JWT audience and scope given some `claims` and some optional
  `options`.
  """
  @spec verify_claims(map(), term()) :: {:ok, map()} | {:error, term()}
  def verify_claims(claims, options)

  def verify_claims(claims, _options) do
    with :ok <- verify_audience(claims),
         :ok <- verify_scope(claims) do
      {:ok, claims}
    end
  end

  #########
  # Helpers

  @doc """
  Use `resource` attribute from Guachiman's config to retrieve a configuration.

  By default use `resource` function from Guachiman.Guardian
  """
  def resolve_resource(subject) do
    {mod, fun, args} = Application.get_env(:guachiman, :resource, {__MODULE__, :resource, []})

    case apply(mod, fun, [subject | args]) do
      {:ok, resource} -> {:ok, resource}
      {:error, error} -> {:error, error}
      _ -> {:error, "Invalid resource"}
    end
  end

  @doc false
  def resource(subject) do
    {:ok, subject}
  end

  #  @doc false
  #  def get_resource_from_db(resource_id) do
  #    query =
  #      AuthUser
  #      |> preload(:organization)
  #      |> where([a], a.user_id == ^resource_id)
  #      |> select([a], a)
  #    case Repo.one(query) do
  #      nil ->
  #        {:error, "Invalid resource"}
  #      %AuthUser{} = resource ->
  #        {:ok, resource}
  #    end
  #  end

  @doc false
  def verify_audience(%{"aud" => audience}) do
    if is_valid_audience?(audience) do
      :ok
    else
      {:error, "Invalid audience"}
    end
  end

  def verify_audience(_), do: :ok

  @doc false
  def is_valid_audience?(audience) when is_binary(audience) do
    audience in get_valid_audiences()
  end

  def is_valid_audience?(audiences) when is_list(audiences) do
    valid_audiences = get_valid_audiences()
    Enum.any?(audiences, fn audience -> audience in valid_audiences end)
  end

  def is_valid_audience?(_) do
    false
  end

  @doc false
  def get_valid_audiences do
    case config(:audience) do
      audience when is_binary(audience) ->
        [audience]

      audiences when is_list(audiences) ->
        audiences

      _ ->
        []
    end
  end

  @doc false
  def verify_scope(%{"scope" => scope}) do
    if is_valid_scope?(scope) do
      :ok
    else
      {:error, "Invalid scope"}
    end
  end

  def verify_scope(_), do: :ok

  @doc false
  def is_valid_scope?(scope) when is_binary(scope) do
    valid_scopes = get_valid_scopes()

    scope
    |> String.split()
    |> Enum.all?(fn scope -> scope in valid_scopes end)
  end

  def is_valid_scope?(_) do
    false
  end

  @doc false
  def get_valid_scopes do
    Application.get_env(:guachiman, :scopes, [])
  end
end
