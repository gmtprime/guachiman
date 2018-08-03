defmodule Guachiman.Pipeline do
  defmacro __using__(options \\ []) do
    otp_app = Keyword.get(options, :otp_app, :guachiman)

    quote do
      use Guardian.Plug.Pipeline, otp_app: unquote(otp_app)
    end
  end
end

defmodule Guachiman.Auth0Pipeline do
  use Guachiman.Pipeline

  plug(Guardian.Plug.VerifyHeader, realm: "Bearer")
  plug(Guardian.Plug.EnsureAuthenticated)
  plug(Guardian.Plug.LoadResource)
end

defmodule Guachiman.Auth0AppsPipeline do
  use Guachiman.Pipeline

  def get_claims() do
    audience = Application.get_env(:guachiman, :apps_audience)

    if audience do
      %{"aud" => audience}
    else
      %{}
    end
  end

  plug(Guardian.Plug.VerifyHeader, realm: "Bearer")
  plug(Guardian.Plug.EnsureAuthenticated)
  #  plug(Guardian.Plug.EnsureAuthenticated, claims: get_claims())
end
