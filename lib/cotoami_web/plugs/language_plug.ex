defmodule CotoamiWeb.LanguagePlug do
  @moduledoc """
  Detect client language
  """
  import Plug.Conn
  require Logger

  @assign_key_language :lang

  def init(default_lang), do: default_lang

  def call(conn, default_lang) do
    lang = List.first(extract_accept_language(conn)) || default_lang
    assign(conn, @assign_key_language, lang)
  end

  defp extract_accept_language(conn) do
    case get_req_header(conn, "accept-language") do
      [value|_] ->
        value
        |> String.split(",")
        |> Enum.map(&parse_language_option/1)
        |> Enum.sort(&(&1.quality > &2.quality))
        |> Enum.map(&(&1.tag))
      _ ->
        []
    end
  end

  defp parse_language_option(string) do
    captures = ~r/^(?<tag>[\w\-]+)(?:;q=(?<quality>[\d\.]+))?$/i
    |> Regex.named_captures(string)

    quality = case Float.parse(captures["quality"] || "1.0") do
      {val, _} -> val
      _ -> 1.0
    end

    %{tag: captures["tag"], quality: quality}
  end
end
