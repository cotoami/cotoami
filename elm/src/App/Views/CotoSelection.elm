module App.Views.CotoSelection exposing (..)

import Set
import Html exposing (..)
import Html.Keyed
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import Utils exposing (onLinkButtonClick, isBlank)
import App.Types.Context exposing (CotoSelection, Context)
import App.Types.Coto exposing (Coto, CotoId, Cotonoma)
import App.Types.Graph exposing (Graph)
import App.Model exposing (..)
import App.Messages exposing (..)
import App.Markdown
import App.Views.Coto


cotoSelectionColumnDiv : Model -> Html Msg
cotoSelectionColumnDiv model =
    div [ id "coto-selection" ]
        [ div
            [ class "column-header" ]
            [ selectionInfoDiv model
            , cotoSelectionToolsDiv model
            , a [ class "tool-button close-selection"
                , href "/"
                , onLinkButtonClick ClearSelection
                ]
                [ i [ class "material-icons" ] [ text "close" ] ]
            ]
        , div
            [ class "column-body" ]
            [ selectedCotosDiv model ]
        ]


selectionInfoDiv : Model -> Html Msg
selectionInfoDiv model =
    div [ class "selection-info" ]
        [ i [ class "fa fa-check-square-o", (attribute "aria-hidden" "true") ] []
        , span
            [ class "selection-count" ]
            [ text (model.context.selection |> List.length |> toString) ]
        , span
            [ class "text" ]
            [ text " cotos selected" ]
        ]


cotoSelectionToolsDiv : Model -> Html Msg
cotoSelectionToolsDiv model =
    if model.connectMode then
        div [] []
    else
        div [ class "selection-tools" ]
          [ button
              [ class "button", onClick ConfirmPinSelectedCotos ]
              [ i [ class "fa fa-thumb-tack", (attribute "aria-hidden" "true") ] []
              , text "Pin"
              ]
          , button
              [ class "button", onClick (SetConnectMode True) ]
              [ text "Connect" ]
          , span
              [ class "selection-title" ]
              [ input
                  [ type_ "text"
                  , name "title"
                  , placeholder "Title for this group"
                  , maxlength titleMaxlength
                  , value model.cotoSelectionTitle
                  , onInput CotoSelectionTitleInput
                  ] []
              , button
                  [ class "button"
                  , disabled (not (validateTitle model.cotoSelectionTitle))
                  , onClick ConfirmCreateGroupingCoto
                  ]
                  [ text "Save" ]
              ]
          ]


titleMaxlength : Int
titleMaxlength = 30


validateTitle : String -> Bool
validateTitle title =
    not (isBlank title) && (String.length title) <= titleMaxlength


selectedCotosDiv : Model -> Html Msg
selectedCotosDiv model =
    Html.Keyed.node
        "div"
        [ id "selected-cotos" ]
        (List.filterMap
            (\cotoId ->
                case getCoto cotoId model of
                    Nothing -> Nothing
                    Just coto -> Just
                        ( toString cotoId
                        , cotoDiv
                            (model.context.deselecting |> Set.member cotoId)
                            model.context
                            model.graph
                            coto
                        )
            )
            (List.reverse model.context.selection)
        )


cotoDiv : Bool -> Context -> Graph -> Coto -> Html Msg
cotoDiv beingDeselected context graph coto =
    div
        [ classList
            [ ( "coto", True )
            , ( "animated", True )
            , ( "fadeOut", beingDeselected )
            ]
        ]
        [ div
            [ class "coto-inner" ]
            [ a [ class "tool-button deselect-coto"
                , title "Deselect coto"
                , onLinkButtonClick (DeselectingCoto coto.id)
                ]
                [ i [ class "material-icons" ]
                    [ if beingDeselected then
                        text "check_box_outline_blank"
                      else
                        text "check_box"
                    ]
                ]
            , App.Views.Coto.headerDiv CotonomaClick context.cotonoma graph coto
            , bodyDiv context graph coto
            , App.Views.Coto.openTraversalButtonDiv OpenTraversal (Just coto.id) graph
            ]
        ]


bodyDiv : Context -> Graph -> Coto -> Html Msg
bodyDiv context graph coto =
    App.Views.Coto.bodyDivWithConfig
        context
        graph
        { openCoto = Nothing
        , selectCoto = Nothing
        , openTraversal = Nothing
        , cotonomaClick = CotonomaClick
        , deleteConnection = Nothing
        , markdown = App.Markdown.markdown
        }
        { cotoId = Just coto.id
        , content = coto.content
        , asCotonoma = coto.asCotonoma
        , cotonomaKey = coto.cotonomaKey
        }


cotoSelectionTools : Model -> Html Msg
cotoSelectionTools model =
    div [ id "coto-selection-tools"
        , classList
            [ ( "empty", List.isEmpty model.context.selection )
            , ( "in-connect-mode", model.connectMode )
            ]
        ]
        [ a [ class "close", onClick ClearSelection ]
            [ i [ class "fa fa-times", (attribute "aria-hidden" "true") ] [] ]
        , if model.connectMode then
            div [ class "connect-mode" ]
                [ span
                    [ class "connect-mode-message" ]
                    [ text "Select a target coto..." ]
                , button
                    [ class "button", onClick (SetConnectMode False) ]
                    [ text "Cancel" ]
                ]
          else
            div [ class "default" ]
                [ selectionInfoDiv model
                , div [ class "buttons" ]
                    [ button
                       [ class "button", onClick ConfirmPinSelectedCotos ]
                       [ i [ class "fa fa-thumb-tack", (attribute "aria-hidden" "true") ] []
                       , text "Pin"
                       ]
                    , button
                       [ class "button", onClick (SetConnectMode True) ]
                       [ text "Connect" ]
                    ]
                ]
        ]
