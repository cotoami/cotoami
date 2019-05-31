module App.Update.Graph exposing (connect, connectToSelection, pin)

import App.Commands
import App.Messages exposing (Msg)
import App.Server.Graph
import App.Submodels.Context exposing (Context)
import App.Submodels.CotoSelection
import App.Submodels.LocalCotos exposing (LocalCotos)
import App.Types.Connection exposing (Direction)
import App.Types.Coto exposing (Coto, CotoId)
import App.Types.Graph.Connect
import Http
import Utils.UpdateUtil exposing (..)


pin :
    Context context
    -> (Result Http.Error String -> Msg)
    -> CotoId
    -> LocalCotos model
    -> ( LocalCotos model, Cmd Msg )
pin context tag cotoId model =
    Maybe.map2
        (\session coto ->
            { model
                | graph =
                    App.Types.Graph.Connect.pin
                        session.amishi.id
                        coto
                        Nothing
                        model.graph
            }
                |> withCmd
                    (\_ ->
                        App.Server.Graph.pinCotos
                            tag
                            context.clientId
                            (Maybe.map .key context.cotonoma)
                            [ cotoId ]
                    )
                |> addCmd
                    (\_ ->
                        App.Commands.scrollPinnedCotosToBottom
                            (\_ -> App.Messages.NoOp)
                    )
        )
        context.session
        (App.Submodels.LocalCotos.getCoto cotoId model)
        |> Maybe.withDefault ( model, Cmd.none )


connect :
    Context context
    -> (Result Http.Error (List String) -> msg)
    -> CotoId
    -> List Coto
    -> Direction
    -> Maybe String
    -> LocalCotos model
    -> ( LocalCotos model, Cmd msg )
connect context tag cotoId objects direction linkingPhrase model =
    model
        |> App.Submodels.LocalCotos.getCoto cotoId
        |> Maybe.map
            (\target ->
                ( App.Submodels.LocalCotos.connect
                    context.session
                    target
                    objects
                    direction
                    linkingPhrase
                    model
                , App.Server.Graph.connect
                    tag
                    context.clientId
                    (Maybe.map .key model.cotonoma)
                    target.id
                    (List.map .id objects)
                    direction
                    linkingPhrase
                )
            )
        |> Maybe.withDefault ( model, Cmd.none )


connectToSelection :
    Context context
    -> (Result Http.Error (List String) -> msg)
    -> CotoId
    -> Direction
    -> Maybe String
    -> LocalCotos model
    -> ( LocalCotos model, Cmd msg )
connectToSelection context tag cotoId direction linkingPhrase model =
    connect
        context
        tag
        cotoId
        (App.Submodels.CotoSelection.cotosInSelectedOrder context)
        direction
        linkingPhrase
        model
