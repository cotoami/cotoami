defmodule Cotoami.RedisService do
  require Logger
  
  @default_host "localhost"
  @default_port 6379
  
  def get_cotos(anonymous_id) do
    {:ok, conn} = start()
    cotos =
      case Redix.command(conn, ["LRANGE", anonymous_id, "0", "1000"]) do
        {:ok, cotos} ->
          if cotos do
            Enum.map(cotos, &(Poison.decode!(&1)))
          else
            []
          end
        {:error, reason} ->
          Logger.error "Redis error #{reason}"
          []
      end
    stop(conn)
    cotos
  end
  
  def add_coto(anonymous_id, coto) do
    coto_as_json = Poison.encode!(coto)
    {:ok, conn} = start()
    Redix.command!(conn, ["LPUSH", anonymous_id, coto_as_json])
    stop(conn)
  end
  
  defp host() do
    Application.get_env(:cotoami, __MODULE__, []) 
    |> Keyword.get(:host)
    || @default_host
  end
  
  defp start() do
    Redix.start_link(host: host(), port: @default_port)
  end
  
  defp stop(conn) do
    Redix.stop(conn)
  end
end
