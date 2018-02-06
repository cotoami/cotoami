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


setQuerying : String -> SearchResults -> SearchResults
setQuerying query searchResults =
    setQuery query searchResults
        |> (\searchResults -> { searchResults | loading = True })


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


clearQuery : SearchResults -> SearchResults
clearQuery searchResults =
    { searchResults
        | query = ""
        , loading = False
        , posts = []
        , inputResetKey = searchResults.inputResetKey + 1
    }


setLoading : SearchResults -> SearchResults
setLoading searchResults =
    { searchResults | loading = True }


setPosts : List Post -> SearchResults -> SearchResults
setPosts posts searchResults =
    { searchResults
        | loading = False
        , posts = posts
    }


getCoto : CotoId -> SearchResults -> Maybe Coto
getCoto cotoId searchResults =
    App.Types.Post.getCotoFromPosts cotoId searchResults.posts
