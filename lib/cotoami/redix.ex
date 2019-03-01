defmodule Cotoami.Redix do
  @moduledoc """
  Provides Redix related functions hiding the connection pool handling
  """

  require Logger

  @default_host "localhost"
  @default_port 6379
  @redix_pool_size 8

  def host() do
    :cotoami
    |> Application.get_env(__MODULE__, [])
    |> Keyword.get(:host) || @default_host
  end

  def port() do
    :cotoami
    |> Application.get_env(__MODULE__, [])
    |> Keyword.get(:port) || @default_port
  end

  # An optional way to specify a redis server
  def url() do
    :cotoami
    |> Application.get_env(__MODULE__, [])
    |> Keyword.get(:url)
  end

  def redix_pool_size(), do: @redix_pool_size

  def command(command, opts \\ []) do
    Redix.command(get_pid(), command, opts)
  end

  def command!(command, opts \\ []) do
    Redix.command!(get_pid(), command, opts)
  end

  defp get_pid() do
    :"redix_#{random_index()}"
  end

  defp random_index() do
    rem(System.unique_integer([:positive]), @redix_pool_size)
  end
end
