defmodule Cotoami.CotoSearchService do
  @moduledoc """
  Provides Coto full-text search functions.
  """

  require Logger
  import Ecto.Query
  alias Cotoami.Amishi

  def search(query, %Amishi{} = amishi, search_string) do
    add_query(query, amishi, normalize(search_string))
  end

  defmacro matching_coto_ids_and_ranks(search_string) do
    quote do
      fragment(
        """
        SELECT 
          coto_search.id AS id,
          ts_rank(
            coto_search.document, 
            plainto_tsquery(unaccent(?))
          ) AS rank
        FROM cotos
        LEFT JOIN coto_search ON coto_search.id = cotos.id
        WHERE 
          coto_search.document @@ plainto_tsquery(unaccent(?)) OR
          cotos.summary ILIKE ? OR
          cotos.content ILIKE ?
        """,
        ^unquote(search_string),
        ^unquote(search_string),
        ^"%#{unquote(search_string)}%",
        ^"%#{unquote(search_string)}%"
      )
    end
  end

  defp add_query(query, %Amishi{} , ""), do: query
  defp add_query(query, %Amishi{id: amishi_id} , search_string) do
    from coto in query,
      join: id_and_rank in matching_coto_ids_and_ranks(search_string),
        on: id_and_rank.id == coto.id,
      left_join: cotonoma in assoc(coto, :posted_in),
      where: 
        coto.amishi_id == ^amishi_id or 
        cotonoma.owner_id == ^amishi_id,
      order_by: [desc: id_and_rank.rank, desc: coto.inserted_at]
  end

  defp normalize(search_string) do
    search_string
    |> String.downcase
    |> String.replace(~r/\n/, " ")
    |> String.replace(~r/\t/, " ")
    |> String.replace(~r/\s{2,}/, " ")
    |> String.trim
  end
end

