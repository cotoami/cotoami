module App.Types.SearchResults exposing (..)

import Util.StringUtil
import App.Types.Post exposing (Post)
import App.Types.Coto exposing (Coto, CotoId)


type alias SearchResults =
    { query : String
    , loading : Bool
    , posts : List Post
    , inputResetKey : Int
    }


defaultSearchResults : SearchResults
defaultSearchResults =
    { query = ""
    , loading = False
    , posts = []
    , inputResetKey = 0
    }


hasQuery : SearchResults -> Bool
hasQuery searchResults =
    Util.StringUtil.isNotBlank searchResults.query


setQuery : String -> SearchResults -> SearchResults
setQuery query searchResults =
    { searchResults
        | query = query
        , loading = True
        , posts =
            if Util.StringUtil.isBlank query then
                []
            else
                searchResults.posts
    }


clearQuery : SearchResults -> SearchResults
clearQuery searchResults =
    { searchResults
        | query = ""
        , loading = False
        , posts = []
        , inputResetKey = searchResults.inputResetKey + 1
    }


setPosts : List Post -> SearchResults -> SearchResults
setPosts posts searchResults =
    { searchResults
        | loading = False
        , posts = posts
    }


getCoto : CotoId -> SearchResults -> Maybe Coto
getCoto cotoId searchResults =
    App.Types.Post.getCotoFromPosts cotoId searchResults.posts
