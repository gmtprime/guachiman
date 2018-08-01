defmodule Guachiman.Resource do
  @moduledoc """
  Define a contract to retrieve the resource required by Guardian
  """

  @callback get(binary()) :: {:ok, any()} | {:error, any()}
  @callback get(binary(), Keyword.t()) :: {:ok, any()} | {:error, any()}
end
