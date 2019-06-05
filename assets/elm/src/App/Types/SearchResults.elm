module App.Types.SearchResults exposing
    ( SearchResults
    , clearQuery
    , defaultSearchResults
    , getCoto
    , hasQuery
    , setLoading
    , setPosts
    , setQuery
    , setQuerying
    )

import App.Types.Coto exposing (Coto, CotoId)
import App.Types.Post exposing (Post)
import Utils.StringUtil


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
    Utils.StringUtil.isNotBlank searchResults.query


setQuerying : String -> SearchResults -> SearchResults
setQuerying query searchResults =
    searchResults
        |> setQuery query
        |> setLoading


setQuery : String -> SearchResults -> SearchResults
setQuery query searchResults =
    { searchResults
        | query = query
        , posts =
            if Utils.StringUtil.isBlank query then
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
