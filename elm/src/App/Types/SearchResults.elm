module App.Types.SearchResults exposing (..)

import App.Types.Post exposing (Post)


type alias SearchResults =
    { open : Bool
    , loading : Bool
    , posts : List Post
    }


defaultSearchResults : SearchResults
defaultSearchResults =
    { open = False
    , loading = False
    , posts = []
    }
