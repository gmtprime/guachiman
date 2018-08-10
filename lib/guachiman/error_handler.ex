defmodule Guachiman.AuthErrorHandler do
  require Logger

  def auth_error(conn, {type, reason}, _opts) do
    # TODO log client and reason the authentication failed
    Logger.info("#{type} - #{reason}")

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
