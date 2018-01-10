module App.Views.CotoSelection exposing (..)

import Set
import Html exposing (..)
import Html.Keyed
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import Util.StringUtil exposing (isBlank)
import Util.EventUtil exposing (onLinkButtonClick)
import Util.HtmlUtil exposing (faIcon, materialIcon)
import App.Types.Context exposing (CotoSelection, Context)
import App.Types.Coto exposing (Coto, CotoId, ElementId, Cotonoma)
import App.Types.Graph exposing (Graph)
import App.Model exposing (..)
import App.Messages exposing (..)
import App.Markdown
import App.Views.Coto


statusBar : Model -> Html Msg
statusBar model =
    div
        [ id "coto-selection-bar"
        , classList
            [ ( "empty", List.isEmpty model.context.selection )
            ]
        ]
        [ a [ class "close", onClick ClearSelection ]
            [ faIcon "times" Nothing ]
        , div [ class "selection-info" ]
            [ faIcon "check-square-o" Nothing
            , span
                [ class "selection-count" ]
                [ text (model.context.selection |> List.length |> toString) ]
            , span
                [ class "text" ]
                [ text " cotos selected" ]
            , a [ class "toggle", onClick CotoSelectionColumnToggle ]
                [ if model.cotoSelectionColumnOpen then
                    faIcon "caret-up" Nothing
                  else
                    faIcon "caret-down" Nothing
                ]
            ]
        ]


cotoSelectionColumnDiv : Model -> Html Msg
cotoSelectionColumnDiv model =
    div [ id "coto-selection" ]
        [ div
            [ class "column-header" ]
            []
        , div
            [ class "column-body" ]
            [ selectedCotosDiv model ]
        ]


titleMaxlength : Int
titleMaxlength =
    30


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
                    Nothing ->
                        Nothing

                    Just coto ->
                        Just
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
    let
        elementId =
            "selection-" ++ coto.id
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
                    , onLinkButtonClick (DeselectingCoto coto.id)
                    ]
                    [ materialIcon
                        (if beingDeselected then
                            "check_box_outline_blank"
                         else
                            "check_box"
                        )
                        Nothing
                    ]
                , App.Views.Coto.headerDiv
                    context
                    graph
                    Nothing
                    { openCotoMenu = Nothing
                    , selectCoto = Nothing
                    , pinCoto = Nothing
                    , editCoto = Nothing
                    , addCoto = Nothing
                    , openTraversal = Nothing
                    , confirmConnect = Nothing
                    , deleteConnection = Nothing
                    }
                    coto
                , App.Views.Coto.bodyDiv context elementId App.Markdown.markdown coto
                , App.Views.Coto.subCotosEllipsisDiv OpenTraversal (Just coto.id) graph
                ]
            ]
