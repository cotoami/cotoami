defmodule Cotoami.Auth do
  @moduledoc """
  Provides authentication as a plug
  """

  import Plug.Conn
  require Logger
  alias Cotoami.AmishiService

  @session_key_amishi_id :amishi_id
  @assign_key_amishi :amishi

  def init(options) do
    options
  end

  def call(conn, _opts) do
    case get_amishi_from_session(conn) do
      nil -> conn
      amishi -> assign_amishi(conn, amishi)
    end
  end

  def get_amishi_from_session(conn) do
    case get_session(conn, @session_key_amishi_id) do
      nil -> nil
      old_id when is_integer(old_id) -> nil
      amishi_id -> AmishiService.get(amishi_id)
    end
  end

  defp assign_amishi(conn, amishi) do
    Logger.info "assign_amishi: #{inspect amishi}"
    Logger.metadata(user_token: (if amishi, do: amishi.email, else: nil))
    assign(conn, @assign_key_amishi, amishi)
  end

  def start_session(conn, amishi) do
    conn |> put_session(@session_key_amishi_id, amishi.id)
  end

  def require_auth(conn, _opts) do
    if conn.assigns[@assign_key_amishi] do
      conn
    else
      conn
      |> send_resp(:unauthorized, "")
      |> halt()
    end
  end
end
