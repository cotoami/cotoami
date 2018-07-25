module App.Commands.Graph
    exposing
        ( renderGraph
        , renderGraphWithDelay
        , resizeGraphWithDelay
        )

import Task
import Process
import Time
import App.Types.Graph exposing (PinnedCotosView(..))
import App.Messages exposing (Msg(RenderGraph, ResizeGraph))
import App.Model exposing (Model)
import App.Ports.Graph


renderGraph : Model -> Cmd Msg
renderGraph model =
    if model.pinnedCotosView == GraphView then
        App.Ports.Graph.renderCotoGraph model.context.cotonoma model.graph
    else
        Cmd.none


renderGraphWithDelay : Cmd Msg
renderGraphWithDelay =
    Process.sleep (100 * Time.millisecond)
        |> Task.andThen (\_ -> Task.succeed ())
        |> Task.perform (\_ -> RenderGraph)


resizeGraphWithDelay : Cmd Msg
resizeGraphWithDelay =
    Process.sleep (100 * Time.millisecond)
        |> Task.andThen (\_ -> Task.succeed ())
        |> Task.perform (\_ -> ResizeGraph)
