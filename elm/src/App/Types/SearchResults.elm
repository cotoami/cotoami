module App.Types.SearchResults exposing (..)

import Util.StringUtil
import App.Types.Post exposing (Post)


type alias SearchResults =
    { query : String
    , loading : Bool
    , posts : List Post
    }


defaultSearchResults : SearchResults
defaultSearchResults =
    { query = ""
    , loading = False
    , posts = []
    }


hasQuery : SearchResults -> Bool
hasQuery searchResults =
    Util.StringUtil.isNotBlank searchResults.query
