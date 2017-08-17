module App.View exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Exts.Maybe exposing (isNothing)
import App.Types.Traversal
import App.ActiveViewOnMobile exposing (ActiveViewOnMobile(..))
import App.Model exposing (..)
import App.Messages exposing (..)
import App.Views.AppHeader
import App.Views.Timeline
import App.Views.Traversals
import App.Views.Navigation
import Components.ConfirmModal.View
import Components.SigninModal
import Components.ProfileModal
import Components.CotoModal
import Components.CotoSelection.View
import Components.CotonomaModal.View
import Components.PinnedCotos
import Components.ConnectModal


view : Model -> Html Msg
view model =
    let
        anyAnonymousCotos =
            (isNothing model.context.session)
                && not (List.isEmpty model.timeline.posts)
        activeViewOnMobile =
            case model.activeViewOnMobile of
                TimelineView -> "timeline"
                PinnedView -> "pinned"
                TraversalsView -> "traversals"
                SelectionView -> "selection"
    in
      div [ id "app"
          , classList
              [ ( "cotonomas-loading", model.cotonomasLoading )
              , ( activeViewOnMobile ++ "-view-on-mobile", True )
              , ( "in-connect-mode", model.connectMode )
              ]
          ]
          [ App.Views.AppHeader.view model
          , div [ id "app-body" ]
                [ div [ id "app-layout" ]
                    (List.concat
                        [ defaultColumnDivs model
                        , App.Views.Traversals.view
                            (model.activeViewOnMobile == TraversalsView)
                            model.context
                            model.graph
                            model.traversals
                        , [ selectionColumnDiv model
                          , viewSwitchContainerDiv model
                          ]
                        ]
                    )
                ]
          , Html.map CotoSelectionMsg
              (Components.CotoSelection.View.cotoSelectionTools model)
          , Html.map ConfirmModalMsg
              (Components.ConfirmModal.View.view model.confirmModal)
          , Html.map SigninModalMsg
              (Components.SigninModal.view model.signinModal anyAnonymousCotos)
          , Html.map ProfileModalMsg
              (Components.ProfileModal.view model.context.session model.profileModal)
          , Html.map CotoModalMsg
              (Components.CotoModal.view model.cotoModal)
          , Html.map CotonomaModalMsg
              (Components.CotonomaModal.View.view model.context.session model.cotonomaModal)
          , Components.ConnectModal.view model
          , a
              [ class "tool-button info-button"
              , title "News and Feedback"
              , href "https://twitter.com/cotoami"
              , target "_blank"
              , hidden (model.timeline.editingNew)
              ]
              [ i [ class "material-icons" ] [ text "info" ] ]
          ]


defaultColumnDivs : Model -> List (Html Msg)
defaultColumnDivs model =
    [ div
        [ id "main-nav"
        , classList
            [ ( "neverToggled", not model.navigationToggled )
            , ( "empty", isNavigationEmpty model )
            , ( "notEmpty", not (isNavigationEmpty model) )
            , ( "animated", model.navigationToggled )
            , ( "slideInDown", model.navigationToggled && model.navigationOpen )
            , ( "slideOutUp", model.navigationToggled && not model.navigationOpen )
            ]
        ] (App.Views.Navigation.view model)
    , div
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
    , div
        [ id "main-stock"
        , classList
            [ ( "main-column", True )
            , ( "activeOnMobile", model.activeViewOnMobile == PinnedView )
            , ( "animated", model.activeViewOnMobile == PinnedView )
            , ( "fadeIn", model.activeViewOnMobile == PinnedView )
            ]
        ]
        [ Components.PinnedCotos.view model.context model.graph
        ]
    ]


selectionColumnDiv : Model -> Html Msg
selectionColumnDiv model =
    div
        [ id "main-selection"
        , classList
            [ ( "main-column", True )
            , ( "activeOnMobile", model.activeViewOnMobile == SelectionView )
            , ( "animated", True )
            , ( "fadeIn", not (List.isEmpty model.context.selection) )
            , ( "empty", List.isEmpty model.context.selection )
            ]
        ]
        [ Html.map CotoSelectionMsg
            (Components.CotoSelection.View.cotoSelectionColumnDiv model)
        ]


viewSwitchContainerDiv : Model -> Html Msg
viewSwitchContainerDiv model =
    div
        [ id "view-switch-container" ]
        [ viewSwitchDiv
            "switch-to-timeline"
            "fa-comments"
            "Switch to timeline"
            (model.activeViewOnMobile == TimelineView)
            False
            (SwitchViewOnMobile TimelineView)
        , viewSwitchDiv
            "switch-to-pinned"
            "fa-thumb-tack"
            "Switch to pinned cotos"
            (model.activeViewOnMobile == PinnedView)
            (isStockEmpty model)
            (SwitchViewOnMobile PinnedView)
        , viewSwitchDiv
            "switch-to-traversals"
            "fa-share-alt"
            "Switch to traversals"
            (model.activeViewOnMobile == TraversalsView)
            (App.Types.Traversal.isEmpty model.traversals)
            (SwitchViewOnMobile TraversalsView)
        , viewSwitchDiv
            "switch-to-selection"
            "fa-check-square-o"
            "Switch to coto selection"
            (model.activeViewOnMobile == SelectionView)
            (List.isEmpty model.context.selection)
            (SwitchViewOnMobile SelectionView)
        ]


viewSwitchDiv : String -> String -> String -> Bool -> Bool -> Msg -> Html Msg
viewSwitchDiv divId iconName buttonTitle selected empty onClickMsg =
    let
        icon = i [ class ("fa " ++ iconName), (attribute "aria-hidden" "true") ] []
    in
        div
            [ id divId
            ,  classList
                [ ( "view-switch", True )
                , ( "selected", selected )
                , ( "empty", empty )
                ]
            ]
            [ if selected || empty then
                span [ class "tool-button" ] [ icon ]
              else
                a [ class "tool-button"
                  , title buttonTitle
                  , onClick onClickMsg
                  ]
                  [ icon ]
            ]
