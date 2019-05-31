module App.Update.Graph exposing (connectToSelection, pin)

import App.Commands
import App.Messages exposing (Msg)
import App.Server.Graph
import App.Submodels.Context exposing (Context)
import App.Submodels.CotoSelection
import App.Submodels.LocalCotos exposing (LocalCotos)
import App.Types.Connection exposing (Direction)
import App.Types.Coto exposing (CotoId)
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


connectToSelection :
    Context context
    -> CotoId
    -> Direction
    -> Maybe String
    -> LocalCotos model
    -> ( LocalCotos model, Cmd Msg )
connectToSelection context cotoId direction linkingPhrase model =
    model
        |> App.Submodels.LocalCotos.getCoto cotoId
        |> Maybe.map
            (\target ->
                let
                    objects =
                        App.Submodels.CotoSelection.cotosInSelectedOrder context
                in
                ( App.Submodels.LocalCotos.connect
                    context.session
                    target
                    objects
                    direction
                    linkingPhrase
                    model
                , App.Server.Graph.connect
                    context.clientId
                    (Maybe.map .key model.cotonoma)
                    target.id
                    (List.map .id objects)
                    direction
                    linkingPhrase
                )
            )
        |> Maybe.withDefault ( model, Cmd.none )
