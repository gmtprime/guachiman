defmodule Guachiman.Resource do
  @moduledoc """
  Define a contract to retrieve the resource required by Guardian.

  Module implementing this behaviour should be provided through
  `Guachiman` config attribute `resource`.
  """

  @callback get(binary()) :: {:ok, any()} | {:error, any()}
  @callback get(binary(), Keyword.t()) :: {:ok, any()} | {:error, any()}
end
