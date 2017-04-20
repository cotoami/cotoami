defmodule Cotoami.ApiCsrfProtection do
  import Plug.Conn
  require Logger
  
  @unprotected_methods ~w(HEAD GET OPTIONS)
  @custom_header "X-From"
  
  defmodule InvalidApiRequestError do
    defexception message: "invalid api request", plug_status: 403
  end
  
  def init(options) do
    options
  end
  
  def call(conn, _opts) do
    cond do
      verified_request?(conn) ->
        conn
      true ->
        raise InvalidApiRequestError
    end
  end
  
  defp verified_request?(conn) do
    conn.method in @unprotected_methods
      || not cookie_authentication?(conn)
  end
  
  defp cookie_authentication?(conn) do
    true
  end
  
  defp xhr?(conn) do
    "XMLHttpRequest" in get_req_header(conn, "x-requested-with")
  end
end
