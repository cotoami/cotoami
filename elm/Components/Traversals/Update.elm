module Components.Traversals.Update exposing (..)

import Components.Traversals.Messages exposing (..)
import Components.Traversals.Model exposing (..)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            model ! []

        CotoClick cotoId ->
            model ! []

        CotoMouseEnter cotoId ->
            model ! []

        CotoMouseLeave cotoId ->
            model ! []

        OpenCoto coto ->
            model ! []

        SelectCoto cotoId ->
            model ! []

        CotonomaClick key ->
            model ! []

        TraverseClick traverse ->
            ( model |> updateTraversal (doTraverse traverse)
            , Cmd.none
            )

        OpenTraversal cotoId ->
            model ! []

        CloseTraversal cotoId ->
            ( model |> closeTraversal cotoId
            , Cmd.none
            )

        ChangePage pageIndex ->
            { model | activePageIndex = pageIndex } ! []

        ConfirmDeleteConnection ( fromId, toId ) ->
            model ! []

        DeleteConnection ( fromId, toId ) ->
            model ! []
