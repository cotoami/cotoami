module App.Views.CotoSelection exposing
    ( statusBar
    , update
    , view
    )

import App.Commands
import App.I18n.Keys as I18nKeys
import App.Markdown
import App.Messages as AppMsg
import App.Submodels.Context exposing (Context)
import App.Submodels.CotoSelection exposing (CotoSelection)
import App.Submodels.LocalCotos exposing (LocalCotos)
import App.Submodels.NarrowViewport exposing (ActiveView(..), NarrowViewport)
import App.Submodels.WideViewport exposing (WideViewport)
import App.Types.Connection
import App.Types.Coto exposing (Coto, CotoContent, CotoId, Cotonoma, ElementId)
import App.Update.Graph
import App.Update.Post
import App.Views.Coto
import App.Views.CotoSelectionMsg as CotoSelectionMsg exposing (Msg(..))
import Exts.Maybe exposing (isJust)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import Html.Keyed
import Process
import Task
import Time
import Utils.EventUtil exposing (onLinkButtonClick)
import Utils.HtmlUtil exposing (faIcon, materialIcon)
import Utils.UpdateUtil exposing (..)


type alias ViewModel model =
    LocalCotos
        (WideViewport
            (CotoSelection
                { model
                    | creatingPinnedGroup : Bool
                }
            )
        )


statusBar : Context context -> ViewModel model -> Html AppMsg.Msg
statusBar context model =
    let
        count =
            model.selection |> List.length

        message =
            context.i18nText (I18nKeys.CotoSelection_CotosSelected count)
    in
    div
        [ id "coto-selection-bar"
        , classList
            [ ( "empty", List.isEmpty model.selection )
            ]
        ]
        [ a
            [ class "close"
            , onClick (AppMsg.CotoSelectionMsg ClearSelection)
            ]
            [ faIcon "times" Nothing ]
        , div [ class "content" ]
            [ span
                [ class "selection-info"
                , onClick (AppMsg.SwitchViewInNarrowViewport SelectionView)
                ]
                [ faIcon "check-square-o" Nothing
                , span [ class "selection-count" ] [ text (toString count) ]
                , span [ class "text" ] [ text (" " ++ message) ]
                ]
            , a
                [ class "toggle"
                , onClick (AppMsg.CotoSelectionMsg ColumnToggle)
                ]
                [ if model.wideViewport.selectionOpen then
                    faIcon "caret-up" Nothing

                  else
                    faIcon "caret-down" Nothing
                ]
            ]
        ]


view : Context context -> ViewModel model -> Html AppMsg.Msg
view context model =
    div [ id "coto-selection" ]
        [ div
            [ class "column-header" ]
            [ if App.Submodels.CotoSelection.isMultiple model then
                pinAsGroupButton context model

              else
                Utils.HtmlUtil.none
            ]
        , div
            [ class "column-body" ]
            [ selectedCotosDiv context model ]
        ]


pinAsGroupButton : Context context -> ViewModel model -> Html AppMsg.Msg
pinAsGroupButton context model =
    span [ id "pin-as-group-button" ]
        [ button
            [ class "button"
            , disabled model.creatingPinnedGroup
            , onClick
                (AppMsg.OpenConfirmModal
                    (context.i18nText I18nKeys.ConfirmPinSelectionAsGroup)
                    (AppMsg.CotoSelectionMsg PinAsGroup)
                )
            ]
            [ faIcon "thumb-tack" Nothing
            , text (context.i18nText I18nKeys.CotoSelection_PinAsGroup)
            ]
        , if model.creatingPinnedGroup then
            Utils.HtmlUtil.loadingImg

          else
            Utils.HtmlUtil.none
        ]


selectedCotosDiv : Context context -> ViewModel model -> Html AppMsg.Msg
selectedCotosDiv context model =
    model
        |> App.Submodels.CotoSelection.cotosInSelectedOrder
        |> List.map (\coto -> ( toString coto.id, cotoDiv context coto ))
        |> Html.Keyed.node "div" [ id "selected-cotos" ]


cotoDiv : Context context -> Coto -> Html AppMsg.Msg
cotoDiv context coto =
    let
        elementId =
            "selection-" ++ coto.id

        beingDeselected =
            App.Submodels.CotoSelection.isBeingDeselected coto.id context
    in
    div
        [ classList
            [ ( "coto", True )
            , ( "animated", True )
            , ( "fadeOut", beingDeselected )
            ]
        ]
        [ div
            [ class "coto-inner" ]
            [ a
                [ class "tool-button deselect-coto"
                , title "Deselect coto"
                , onLinkButtonClick
                    (AppMsg.CotoSelectionMsg (DeselectingCoto coto.id))
                ]
                [ materialIcon
                    (if beingDeselected then
                        "check_box_outline_blank"

                     else
                        "check_box"
                    )
                    Nothing
                ]
            , App.Views.Coto.headerDiv context Nothing elementId coto
            , App.Views.Coto.bodyDiv context Nothing elementId App.Markdown.markdown coto
            , App.Views.Coto.openTraversalButtonDiv context.graph (isJust coto.asCotonoma) coto.id
            ]
        ]


type alias UpdateModel model =
    Context
        (LocalCotos
            (WideViewport
                (NarrowViewport
                    (CotoSelection
                        { model
                            | creatingPinnedGroup : Bool
                        }
                    )
                )
            )
        )


update :
    Context context
    -> CotoSelectionMsg.Msg
    -> UpdateModel model
    -> ( UpdateModel model, Cmd AppMsg.Msg )
update context msg model =
    case msg of
        ColumnToggle ->
            model
                |> App.Submodels.WideViewport.toggleSelection
                |> withoutCmd

        DeselectingCoto cotoId ->
            model
                |> App.Submodels.CotoSelection.setBeingDeselected cotoId
                |> withCmd
                    (\model ->
                        Process.sleep (1 * Time.second)
                            |> Task.andThen (\_ -> Task.succeed ())
                            |> Task.perform (\_ -> AppMsg.CotoSelectionMsg DeselectCoto)
                    )

        DeselectCoto ->
            model
                |> App.Submodels.CotoSelection.finishBeingDeselected
                |> App.Submodels.WideViewport.closeSelectionIfEmpty context
                |> withoutCmd

        ClearSelection ->
            let
                activeView =
                    case model.narrowViewport.activeView of
                        SelectionView ->
                            FlowView

                        anotherView ->
                            anotherView
            in
            model
                |> App.Submodels.CotoSelection.clear
                |> App.Submodels.WideViewport.closeSelection
                |> App.Submodels.NarrowViewport.switchActiveView activeView
                |> withoutCmd

        PinAsGroup ->
            { model | creatingPinnedGroup = True }
                |> App.Update.Post.post
                    context
                    (\postId ->
                        AppMsg.CotoSelectionMsg
                            << GroupingCotoPosted postId
                    )
                    (CotoContent "" Nothing)

        GroupingCotoPosted postId (Ok post) ->
            post.cotoId
                |> Maybe.map
                    (\cotoId ->
                        App.Submodels.LocalCotos.onPosted postId post model
                            |> App.Update.Graph.pin
                                model
                                (AppMsg.CotoSelectionMsg << GroupingCotoPinned cotoId)
                                cotoId
                    )
                |> Maybe.withDefault ( model, Cmd.none )

        GroupingCotoPosted postId (Err _) ->
            model |> withoutCmd

        GroupingCotoPinned cotoId (Ok _) ->
            App.Update.Graph.connectToSelection
                context
                (AppMsg.CotoSelectionMsg << GroupingConnectionsCreated)
                cotoId
                App.Types.Connection.Outbound
                Nothing
                model

        GroupingCotoPinned cotoId (Err _) ->
            model |> withoutCmd

        GroupingConnectionsCreated (Ok _) ->
            { model | creatingPinnedGroup = False }
                |> App.Submodels.CotoSelection.clear
                |> App.Submodels.NarrowViewport.switchActiveView StockView
                |> withCmd (\_ -> App.Commands.sendMsg AppMsg.GraphChanged)
                |> addCmd
                    (\_ ->
                        App.Commands.scrollPinnedCotosToBottom
                            (\_ -> AppMsg.NoOp)
                    )

        GroupingConnectionsCreated (Err _) ->
            model |> withoutCmd
