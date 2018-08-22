defmodule Guachiman.AuthErrorHandler do
  require Logger

  alias Guachiman.Guardian.Plug, as: GPlug

  def auth_error(conn, {type, reason}, _opts) do
    # log client_id (sub claim) of the request
    client_id =
      case GPlug.current_claims(conn) do
        %{"sub" => sub} -> sub
        _ -> "Unknown client_id"
      end

    Logger.info("#{client_id} - #{type} - #{reason}")

    msg =
      case reason do
        :invalid_token -> "Invalid authentication token"
        :invalid_resource -> "Token doesn't belong to a valid user"
        :invalid_scope -> "Token's scope is not valid"
        :token_expired -> "Token is expired"
        _ -> "Token is not valid"
      end

    err =
      Poison.encode!(%{
        error: to_string(type),
        message: msg
      })

    Plug.Conn.send_resp(conn, 401, err)
  end
end
