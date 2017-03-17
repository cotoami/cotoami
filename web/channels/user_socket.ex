defmodule Cotoami.UserSocket do
  require Logger
  use Phoenix.Socket
  alias Cotoami.Repo

  ## Channels
  channel "cotonomas:*", Cotoami.CotonomaChannel

  ## Transports
  transport :websocket, Phoenix.Transports.WebSocket
  # transport :longpoll, Phoenix.Transports.LongPoll
  
  @max_age 2 * 7 * 24 * 60 * 60

  def connect(%{"token" => token}, socket) do
    Logger.info "Connecting: #{token}"
    case Phoenix.Token.verify(socket, "amishi", token, max_age: @max_age) do
      {:ok, amishi_id} ->
        amishi = Repo.get!(Cotoami.Amishi, amishi_id)
        {:ok, assign(socket, :amishi, amishi)}
      {:error, _reason} ->
        :error
    end
  end
  def connect(_params, _socket), do: :error

  def id(socket), do: "users_socket:#{socket.assigns.amishi.id}"
end
