defmodule Cotoami.Redix do
  @moduledoc """
  Provides Redix related functions hiding the connection pool handling
  """

  require Logger

  @default_host "localhost"
  @default_port 6379
  @redix_pool_size 10

  def host() do
    Application.get_env(:cotoami, __MODULE__, [])
    |> Keyword.get(:host)
    || @default_host
  end

  def port() do
    Application.get_env(:cotoami, __MODULE__, [])
    |> Keyword.get(:port)
    || @default_port
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
