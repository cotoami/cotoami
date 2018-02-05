module App.Types.SearchResults exposing (..)

import Util.StringUtil
import App.Types.Post exposing (Post)


type alias SearchResults =
    { query : String
    , inputResetKey : Int
    , loading : Bool
    , posts : List Post
    }


defaultSearchResults : SearchResults
defaultSearchResults =
    { query = ""
    , inputResetKey = 0
    , loading = False
    , posts = []
    }


hasQuery : SearchResults -> Bool
hasQuery searchResults =
    Util.StringUtil.isNotBlank searchResults.query


setQuery : String -> SearchResults -> SearchResults
setQuery query searchResults =
    { searchResults
        | query = query
        , posts =
            if Util.StringUtil.isBlank query then
                []
            else
                searchResults.posts
    }


setPosts : List Post -> SearchResults -> SearchResults
setPosts posts searchResults =
    { searchResults | posts = posts }
