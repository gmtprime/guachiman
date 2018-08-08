defmodule Guachiman.PipelineTest do
  use ExUnit.Case, async: true
  use Plug.Test

  alias Guachiman.Plug.Pipeline
  #  alias Guachiman.MyPipeline

  test "passing custom audience claim to the plug" do
    conn = conn(:get, "/test")

    aud_value = "my_custom_audience"
    options = Pipeline.init(audience: aud_value)

    new_conn =
      conn
      |> Pipeline.call(options)

    assert Map.has_key?(new_conn.private, :guachiman_audience)
    assert new_conn.private[:guachiman_audience] == aud_value
  end

  test "plugs under Guachiman.Pipeline has access to the audience" do
    defmodule MyPipeline do
      use Guachiman.Plug.Pipeline

      def my_fun_plug(conn, _opts) do
        conn
      end

      plug(:my_fun_plug)
    end

    aud_value = "my_custom_audience"
    conn = conn(:get, "/test")

    options = MyPipeline.init(audience: aud_value)

    new_conn =
      conn
      |> MyPipeline.call(options)

    assert Map.has_key?(new_conn.private, :guachiman_audience)
    assert new_conn.private[:guachiman_audience] == aud_value
  end
end
