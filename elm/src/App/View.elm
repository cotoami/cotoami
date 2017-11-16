module App.View exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Util.HtmlUtil exposing (faIcon, materialIcon)
import App.Types.Traversal
import App.ActiveViewOnMobile exposing (ActiveViewOnMobile(..))
import App.Model exposing (..)
import App.Messages exposing (..)
import App.Views.AppHeader
import App.Views.Timeline
import App.Views.Traversals
import App.Views.Navigation
import App.Views.PinnedCotos
import App.Views.CotoSelection
import App.Modals.ConnectModal
import App.Modals.ProfileModal
import App.Modals.InviteModal
import App.Modals.CotoMenuModal
import App.Modals.CotoModal
import App.Modals.SigninModal
import App.Modals.EditorModal
import App.Modals.ConfirmModal
import App.Modals.ImportModal


view : Model -> Html Msg
view model =
    let
        activeViewOnMobile =
            case model.activeViewOnMobile of
                TimelineView ->
                    "timeline"

                PinnedView ->
                    "pinned"

                TraversalsView ->
                    "traversals"

                SelectionView ->
                    "selection"
    in
        div
            [ id "app"
            , classList
                [ ( "cotonomas-loading", model.cotonomasLoading )
                , ( activeViewOnMobile ++ "-view-on-mobile", True )
                ]
            , onClick AppClick
            ]
            [ App.Views.AppHeader.view model
            , div [ id "app-body" ]
                [ div [ id "app-layout" ]
                    [ navColumn model
                    , graphExplorationDiv model
                    , timelineColumn model
                    , selectionColumn model
                    , viewSwitchContainerDiv model
                    ]
                ]
            , App.Views.CotoSelection.statusBar model
            , a
                [ class "tool-button new-coto-button"
                , title "New Coto"
                , hidden (model.timeline.editorOpen)
                , onClick OpenNewEditorModal
                ]
                [ materialIcon "create" Nothing
                , span [ class "shortcut" ] [ text "(Press N key)" ]
                ]
            , div [] (modals model)
            ]


navColumn : Model -> Html Msg
navColumn model =
    div
        [ id "main-nav"
        , classList
            [ ( "neverToggled", not model.navigationToggled )
            , ( "empty", isNavigationEmpty model )
            , ( "notEmpty", not (isNavigationEmpty model) )
            , ( "animated", model.navigationToggled )
            , ( "slideInDown", model.navigationToggled && model.navigationOpen )
            , ( "slideOutUp", model.navigationToggled && not model.navigationOpen )
            ]
        ]
        (App.Views.Navigation.view model)


graphExplorationDiv : Model -> Html Msg
graphExplorationDiv model =
    div
        [ id "graph-exploration"
        , classList
            [ ( "activeOnMobile"
              , List.member model.activeViewOnMobile [ PinnedView, TraversalsView ]
              )
            ]
        ]
        (pinnedCotosColumn model :: (traversalColumns model))


timelineColumn : Model -> Html Msg
timelineColumn model =
    div
        [ id "main-timeline"
        , classList
            [ ( "main-column", True )
            , ( "activeOnMobile", model.activeViewOnMobile == TimelineView )
            , ( "animated", model.activeViewOnMobile == TimelineView )
            , ( "fadeIn", model.activeViewOnMobile == TimelineView )
            ]
        ]
        [ App.Views.Timeline.view
            model.context
            model.graph
            model.timeline
        ]


pinnedCotosColumn : Model -> Html Msg
pinnedCotosColumn model =
    div
        [ id "main-pinned-cotos"
        , classList
            [ ( "main-column", True )
            , ( "empty", List.isEmpty model.graph.rootConnections )
            , ( "activeOnMobile", model.activeViewOnMobile == PinnedView )
            , ( "animated", model.activeViewOnMobile == PinnedView )
            , ( "fadeIn", model.activeViewOnMobile == PinnedView )
            ]
        ]
        [ App.Views.PinnedCotos.view model.context model.graph
        ]


traversalColumns : Model -> List (Html Msg)
traversalColumns model =
    App.Views.Traversals.view
        (model.activeViewOnMobile == TraversalsView)
        model.context
        model.graph
        model.traversals


selectionColumn : Model -> Html Msg
selectionColumn model =
    div
        [ id "main-selection"
        , classList
            [ ( "main-column", True )
            , ( "activeOnMobile", model.activeViewOnMobile == SelectionView )
            , ( "animated", True )
            , ( "fadeIn", not (List.isEmpty model.context.selection) )
            , ( "empty", List.isEmpty model.context.selection )
            , ( "hidden", not model.cotoSelectionColumnOpen )
            ]
        ]
        [ App.Views.CotoSelection.cotoSelectionColumnDiv model
        ]


viewSwitchContainerDiv : Model -> Html Msg
viewSwitchContainerDiv model =
    div
        [ id "view-switch-container" ]
        [ viewSwitchDiv
            "switch-to-timeline"
            "comments"
            "Switch to timeline"
            (model.activeViewOnMobile == TimelineView)
            False
            (SwitchViewOnMobile TimelineView)
        , viewSwitchDiv
            "switch-to-pinned"
            "thumb-tack"
            "Switch to pinned cotos"
            (model.activeViewOnMobile == PinnedView)
            (isStockEmpty model)
            (SwitchViewOnMobile PinnedView)
        , viewSwitchDiv
            "switch-to-traversals"
            "sitemap"
            "Switch to explorations"
            (model.activeViewOnMobile == TraversalsView)
            (App.Types.Traversal.isEmpty model.traversals)
            (SwitchViewOnMobile TraversalsView)
        , viewSwitchDiv
            "switch-to-selection"
            "check-square-o"
            "Switch to coto selection"
            (model.activeViewOnMobile == SelectionView)
            (List.isEmpty model.context.selection)
            (SwitchViewOnMobile SelectionView)
        ]


viewSwitchDiv : String -> String -> String -> Bool -> Bool -> Msg -> Html Msg
viewSwitchDiv divId iconName buttonTitle selected empty onClickMsg =
    div
        [ id divId
        , classList
            [ ( "view-switch", True )
            , ( "selected", selected )
            , ( "empty", empty )
            ]
        ]
        [ if selected || empty then
            span
                [ class "tool-button" ]
                [ faIcon iconName Nothing ]
          else
            a
                [ class "tool-button"
                , title buttonTitle
                , onClick onClickMsg
                ]
                [ faIcon iconName Nothing ]
        ]


modals : Model -> List (Html Msg)
modals model =
    List.map
        (\modal ->
            case modal of
                ConfirmModal ->
                    App.Modals.ConfirmModal.view model.confirmation.message

                SigninModal ->
                    App.Modals.SigninModal.view model.signinModal

                EditorModal ->
                    App.Modals.EditorModal.view model.context model.editorModal

                ProfileModal ->
                    App.Modals.ProfileModal.view model.context.session

                InviteModal ->
                    App.Modals.InviteModal.view model.inviteModal

                CotoMenuModal ->
                    App.Modals.CotoMenuModal.view model.context model.graph model.cotoMenuModal

                CotoModal ->
                    App.Modals.CotoModal.view model.context.session model.cotoModal

                ConnectModal ->
                    App.Modals.ConnectModal.view model

                ImportModal ->
                    App.Modals.ImportModal.view model.importModal
        )
        (List.reverse model.modals)
