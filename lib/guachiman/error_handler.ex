defmodule Guachiman.AuthErrorHandler do
  def auth_error(conn, {type, reason}, _opts) do
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
