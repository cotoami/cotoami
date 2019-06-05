module App.Update.Post exposing
    ( SearchModel
    , post
    , postCotonoma
    , scrollTimelineIfNeeded
    , search
    )

import App.Commands
import App.Messages exposing (Msg)
import App.Server.Post
import App.Submodels.Context exposing (Context)
import App.Submodels.LocalCotos exposing (LocalCotos)
import App.Types.Coto exposing (CotoContent)
import App.Types.Post exposing (Post)
import App.Types.SearchResults exposing (SearchResults)
import App.Types.Timeline
import Http exposing (Request)
import Utils.StringUtil
import Utils.UpdateUtil exposing (..)


post :
    Context context
    -> (Int -> Result Http.Error Post -> Msg)
    -> CotoContent
    -> LocalCotos model
    -> ( LocalCotos model, Cmd Msg )
post context tag content model =
    let
        ( newTimeline, newPost ) =
            App.Types.Timeline.post context False content model.timeline
    in
    { model | timeline = newTimeline }
        |> withCmd
            (\_ ->
                App.Server.Post.post
                    context.clientId
                    context.cotonoma
                    (tag newTimeline.postIdCounter)
                    newPost
            )
        |> addCmd scrollTimelineIfNeeded


postCotonoma :
    Context context
    -> (Int -> Result Http.Error Post -> Msg)
    -> Bool
    -> String
    -> LocalCotos model
    -> ( LocalCotos model, Cmd Msg )
postCotonoma context tag shared cotonomaName model =
    let
        ( newTimeline, _ ) =
            App.Types.Timeline.post
                context
                True
                (CotoContent cotonomaName Nothing)
                model.timeline
    in
    { model | timeline = newTimeline }
        |> withCmd
            (\_ ->
                App.Server.Post.postCotonoma
                    context.clientId
                    context.cotonoma
                    (tag newTimeline.postIdCounter)
                    shared
                    cotonomaName
            )
        |> addCmd scrollTimelineIfNeeded


scrollTimelineIfNeeded : LocalCotos model -> Cmd Msg
scrollTimelineIfNeeded model =
    if App.Types.Timeline.isScrolledToLatest model.timeline then
        App.Commands.scrollTimelineToBottom (\_ -> App.Messages.NoOp)

    else
        Cmd.none


type alias SearchModel model =
    { model
        | lastSearchId : Int
        , searchResults : SearchResults
    }


search : String -> SearchModel model -> ( SearchModel model, Cmd Msg )
search query model =
    let
        searchId =
            model.lastSearchId + 1

        searchResults =
            App.Types.SearchResults.setQuerying query model.searchResults
    in
    if Utils.StringUtil.isNotBlank query then
        { model | lastSearchId = searchId, searchResults = searchResults }
            |> withCmd (\_ -> App.Server.Post.search searchId query)

    else
        { model | searchResults = searchResults }
            |> withoutCmd
