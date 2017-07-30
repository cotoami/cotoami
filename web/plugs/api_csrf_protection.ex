defmodule Cotoami.ApiCsrfProtection do
  @moduledoc """
  Provides CSRF protection for API access as a plug
  """

  import Plug.Conn
  require Logger

  @unprotected_methods ~w(HEAD GET OPTIONS)
  @custom_header "x-requested-with"

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
      || csrf_safe?(conn)
  end

  defp cookie_authentication?(_conn) do
    true
  end

  defp csrf_safe?(conn) do
    valid_host?(conn)
      && custom_header_exists?(conn)
      && valid_origin?(conn)
  end

  # DNS rebinding attack prevention
  defp valid_host?(conn) do
    %{host: host, port: port} = Cotoami.Endpoint.struct_url()
    host_and_port = "#{host}:#{port}"
    case get_req_header(conn, "host") do
      [^host] ->
        true
      [^host_and_port] ->
        true
      [invalid_host] ->
        Logger.info "invalid host header: #{invalid_host}"
        false
    end
  end

  # Ensure the request has been sent via xhr
  # http://blog.alutam.com/2011/09/14/jersey-and-cross-site-request-forgery-csrf/
  # http://stackoverflow.com/questions/17478731/whats-the-point-of-the-x-requested-with-header
  defp custom_header_exists?(conn) do
    case get_req_header(conn, @custom_header) do
      [_value] ->
        true
      _ ->
        Logger.info "custom header '#{@custom_header}' does not exist"
        false
    end
  end

  # Ensure the xhr request came from the same origin
  defp valid_origin?(conn) do
    case get_req_header(conn, "origin") do
      [origin] ->
        Logger.info "origin header: #{origin}"
        %{scheme: scheme, host: host} = Cotoami.Endpoint.struct_url()
        String.starts_with?(origin, "#{scheme}://#{host}")
      _ ->
        true
    end
  end
end
