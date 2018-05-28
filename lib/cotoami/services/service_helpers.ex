defmodule Cotoami.ServiceHelpers do
  @moduledoc """
  Utility functions for services.
  """

  import Ecto.Query, only: [from: 2, exclude: 2, select: 3]
  alias Cotoami.Repo

  def query_with_pagination(query, page_size, page_index, row_mapper \\ &(&1)) do
    rows = 
      from(query, 
        limit: ^page_size,
        offset: ^(page_index * page_size))
      |> Repo.all()
      |> Enum.map(row_mapper)

    counts = 
      query
      |> exclude(:preload)
      |> exclude(:order_by)
      |> select([row], count(row.id))
      |> Repo.all()
    total_rows = 
      if Enum.empty?(query.group_bys), 
        do: List.first(counts), 
        else: length counts # workaround until the release of https://github.com/elixir-lang/ecto/pull/1231
    
    total_pages = div (total_rows + page_size - 1), page_size
    %{
      rows: rows, 
      page_size: page_size, 
      page_index: page_index, 
      total_rows: total_rows, 
      total_pages: total_pages
    }
  end
end
