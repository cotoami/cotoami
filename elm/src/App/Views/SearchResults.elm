module App.Views.SearchResults exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import App.Types.SearchResults exposing (SearchResults)
import App.Messages exposing (..)


view : SearchResults -> Html Msg
view model =
    div [ id "search-results" ]
        []
