defmodule Guachiman.Plug.MetaPipeline do
  @moduledoc """
  Defines a plug pipeline that applies `Guardian.Plug.Pipeline`
  and use `:guachiman` as its `otp_app`.
  """
  defmacro __using__(options \\ []) do
    otp_app = Keyword.get(options, :otp_app, :guachiman)

    quote do
      use Guardian.Plug.Pipeline, otp_app: unquote(otp_app)
    end
  end
end

defmodule Guachiman.Plug.Pipeline do
  @moduledoc """
  Defines a plug pipeline that applies `Guardian.Plug.Pipeline` and
  uses `:guachiman` as `otp_app`, `Guachiman.Guardian` as Guardian's
  module and `Guachiman.AuthErrorHandler` as error handler for
  `Guardian`.

  The easiest way to use `Guachiman.Plug.Pipeline` is create a module to
  define the custom pipeline.

  ```elixir
  defmodule MyCustomAuth0Pipeline do
    use Guachiman.Plug.Pipeline

  plug(Guardian.Plug.VerifyHeader, realm: "Bearer")
  plug(Guachiman.Plug.EnsureAuthenticated)
  ...

  end
  ```

  Then, when you want to use the module, do the following:

  ```elixir
  plug MyCustomAuth0Pipeline, audience: "my_aut0_api_audience"
  ```

  Similarly, you can also use `Guachiman.Plug.Pipeline` inline to set the audience
  as follows:

 	### Inline pipelines

  If you want to define your pipeline inline, you can do so by using
  `Guachiman.Plug.Pipeline` as a plug itself.

  ```elixir
  plug(Guachiman.Plug.Pipeline, audience: "my_aut0_api_audience")
  plug(Guardian.Plug.VerifyHeader, realm: "Bearer")
  plug(Guachiman.Plug.EnsureAuthenticated)
    ```

  """

  defmacro __using__(options \\ []) do
    alias Guachiman.Plug.Pipeline
    otp_app = Keyword.get(options, :otp_app, :guachiman)
    module = Keyword.get(options, :module, Guachiman.Guardian)
    error_handler = Keyword.get(options, :error_handler, Guachiman.AuthErrorHandler)

    quote do
      use Plug.Builder

      import Pipeline

      plug(
        Guardian.Plug.Pipeline,
        otp_app: unquote(otp_app),
        module: unquote(module),
        error_handler: unquote(error_handler)
      )

      def init(opts) do
        Pipeline.init(opts)
      end

      def call(conn, opts) do
        conn
        |> Pipeline.call(opts)
        |> super(opts)
      end
    end
  end

  ### PUBLIC API

  @spec init(Keyword.t()) :: Keyword.t()
  def init(opts) do
    audience = get_audience(opts)

    opts
    |> Keyword.put(:audience, audience)
  end

  @spec call(Plug.Conn.t(), Keyword.t()) :: Plug.Conn.t()
  def call(conn, opts) do
    conn
    |> put_audience(opts)
  end

  @doc false
  @spec put_audience(Plug.Conn.t(), Keyword.t()) :: Plug.Conn.t()
  def put_audience(conn, opts) do
    conn
    |> Plug.Conn.put_private(:guachiman_audience, Keyword.get(opts, :audience))
  end

  @spec fetch_audience(Plug.Conn.t()) :: binary()
  @doc """
  Fetches the audience assigned to the pipeline.

  Raises an error when the audience hasn't been set.
  """
  def fetch_audience(conn) do
    audience = current_audience(conn)

    if audience do
      audience
    else
      raise("`audience` not set in Guachiman Pipeline")
    end
  end

  ### HELPERS
  defp current_audience(conn), do: conn.private[:guachiman_audience]

  defp get_audience(opts) do
    # get `audience` from plug options or use configuration instead
    opts
    |> Keyword.get(:audience, Application.get_env(:guachiman, :audience))
  end
end

defmodule Guachiman.Plug.Auth0Pipeline do
  use Guachiman.Plug.Pipeline

  plug(Guardian.Plug.VerifyHeader, realm: "Bearer")
  plug(Guachiman.Plug.EnsureAuthenticated)
  plug(Guardian.Plug.LoadResource)
end

defmodule Guachiman.Plug.Auth0AppsPipeline do
  use Guachiman.Plug.Pipeline

  plug(Guardian.Plug.VerifyHeader, realm: "Bearer")
  plug(Guachiman.Plug.EnsureAuthenticated)
end
