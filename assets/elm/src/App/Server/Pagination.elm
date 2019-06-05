module App.Server.Pagination exposing (PaginatedList, decodePaginatedList)

import Json.Decode as Decode exposing (int)
import Json.Decode.Pipeline exposing (required)


type alias PaginatedList a =
    { list : List a
    , pageSize : Int
    , pageIndex : Int
    , totalRows : Int
    , totalPages : Int
    }


decodePaginatedList : Decode.Decoder a -> Decode.Decoder (PaginatedList a)
decodePaginatedList decodeRecord =
    Decode.succeed PaginatedList
        |> required "rows" (Decode.list decodeRecord)
        |> required "page_size" int
        |> required "page_index" int
        |> required "total_rows" int
        |> required "total_pages" int
