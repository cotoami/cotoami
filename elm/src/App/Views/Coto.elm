module App.Views.Coto exposing (..)

import Set
import Dict
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Html.Keyed
import Util.Events exposing (onClickWithoutPropagation, onLinkButtonClick)
import App.Markdown
import App.Types.Context exposing (Context, isSelected)
import App.Types.Coto exposing (Coto, ElementId, CotoId, Cotonoma, CotonomaKey, isPostedInCotonoma)
import App.Types.Graph exposing (Direction(..), Graph, Connection, pinned, hasChildren)
import App.Messages exposing (..)


cotoClassList : Context -> ElementId -> Maybe CotoId -> List (String, Bool) -> Attribute msg
cotoClassList context elementId maybeCotoId additionalClasses =
    classList
        ( [ ( "coto", True )
          , ( "selectable", True )
          , ( "element-focus", Just elementId == context.elementFocus )
          , ( "coto-focus", maybeCotoId == context.cotoFocus )
          , ( "selected", isSelected maybeCotoId context )
          ] ++ additionalClasses
        )


headerDiv : (CotonomaKey -> msg) -> Maybe Cotonoma -> Graph -> Coto -> Html msg
headerDiv cotonomaClick maybeCotonoma graph coto =
    div
        [ class "coto-header" ]
        [ case coto.postedIn of
            Nothing ->
                span [] []

            Just postedIn ->
                if not (isPostedInCotonoma maybeCotonoma coto) then
                    a
                        [ class "posted-in"
                        , href ("/cotonomas/" ++ postedIn.key)
                        , onLinkButtonClick (cotonomaClick postedIn.key)
                        ]
                        [ text postedIn.name ]
                else
                    span [] []
        , if pinned coto.id graph then
            i
                [ class "pinned fa fa-thumb-tack"
                , (attribute "aria-hidden" "true")
                ]
                []
          else if App.Types.Graph.member coto.id graph then
            i
                [ class "connected fa fa-share-alt"
                , (attribute "aria-hidden" "true")
                ]
                []
          else
            span [] []
        ]


type alias BodyModel =
    { cotoId : Maybe CotoId
    , content : String
    , asCotonoma : Bool
    , cotonomaKey : Maybe CotonomaKey
    }


type alias BodyConfig msg =
    { openCoto : Maybe msg
    , selectCoto : Maybe (CotoId -> msg)
    , pinCoto : Maybe (CotoId -> msg)
    , openTraversal : Maybe (CotoId -> msg)
    , cotonomaClick : CotonomaKey -> msg
    , confirmConnect : Maybe (CotoId -> Direction -> msg)
    , deleteConnection : Maybe msg
    , markdown : String -> Html msg
    }


defaultBodyConfig : Maybe ( CotoId, CotoId ) -> Coto -> BodyConfig Msg
defaultBodyConfig maybeConnection coto =
    { openCoto = Just (OpenCoto coto)
    , selectCoto = Just SelectCoto
    , pinCoto = Just PinCoto
    , openTraversal = Just OpenTraversal
    , cotonomaClick = CotonomaClick
    , confirmConnect = Just ConfirmConnect
    , deleteConnection =
        case maybeConnection of
            Nothing -> Nothing
            Just connection -> Just (ConfirmDeleteConnection connection)
    , markdown = App.Markdown.markdown
    }


bodyDivWithConfig : Context -> Graph -> BodyConfig msg -> BodyModel -> Html msg
bodyDivWithConfig context graph config model =
    div [ class "coto-body" ]
        [ (case model.cotoId of
            Nothing ->
                span [] []

            Just cotoId ->
                toolButtonsSpan context graph config model.asCotonoma cotoId
          )
        , if model.asCotonoma then
            let
                content =
                    [ i [ class "material-icons" ] [ text "exit_to_app" ]
                    , span [ class "cotonoma-name" ] [ text model.content ]
                    ]
            in
                div [ class "coto-as-cotonoma" ]
                    [ case model.cotonomaKey of
                        Nothing -> span [] content
                        Just cotonomaKey ->
                            a [ href ("/cotonomas/" ++ cotonomaKey)
                              , onLinkButtonClick (config.cotonomaClick cotonomaKey)
                              ]
                              content
                    ]
          else
            config.markdown model.content
        ]


bodyDiv : Maybe ( CotoId, CotoId ) -> Context -> Graph -> Coto -> Html Msg
bodyDiv maybeConnection context graph coto =
    bodyDivWithConfig
        context
        graph
        (defaultBodyConfig maybeConnection coto)
        { cotoId = Just coto.id
        , content = coto.content
        , asCotonoma = coto.asCotonoma
        , cotonomaKey = coto.cotonomaKey
        }


toolButtonsSpan : Context -> Graph -> BodyConfig msg -> Bool -> CotoId -> Html msg
toolButtonsSpan context graph config asCotonoma cotoId =
    span [ class "coto-tool-buttons" ]
        [ if List.isEmpty context.selection || isSelected (Just cotoId) context then
            span [] []
          else
            case config.confirmConnect of
                Nothing ->
                    span [] []

                Just confirmConnect ->
                    span [ class "connecting-buttons" ]
                        [ a
                            [ class "tool-button connect-to-this"
                            , title "Inbound connection from the selected cotos"
                            , onLinkButtonClick (confirmConnect cotoId Inbound)
                            ]
                            [ i [ class "material-icons" ] [ text "file_download" ] ]
                        , a
                            [ class "tool-button connect-to-selection"
                            , title "Outbound connection to the selected cotos"
                            , onLinkButtonClick (confirmConnect cotoId Outbound)
                            ]
                            [ i [ class "material-icons" ] [ text "file_upload" ] ]
                        ]

        , span [ class "default-buttons" ]
            [ case config.pinCoto of
                Nothing ->
                    span [] []

                Just pinCoto ->
                    if pinned cotoId graph then
                        span [] []
                    else
                        a
                            [ class "tool-button pin-coto"
                            , title "Pin this coto"
                            , onLinkButtonClick (pinCoto cotoId)
                            ]
                            [ i [ class "pinned fa fa-thumb-tack", (attribute "aria-hidden" "true") ] [] ]

            , case config.openTraversal of
                Nothing ->
                    span [] []

                Just openTraversal ->
                    a
                        [ class "tool-button traverse-coto"
                        , title "Traverse from this coto"
                        , onLinkButtonClick (openTraversal cotoId)
                        ]
                        [ i [ class "material-icons" ] [ text "arrow_forward" ] ]

            , case config.openCoto of
                Nothing ->
                    span [] []

                Just openCoto ->
                    a
                        [ class "tool-button open-coto"
                        , title "Open coto view"
                        , onLinkButtonClick openCoto
                        ]
                        [ i [ class "material-icons" ] [ text "settings" ] ]

            , case config.deleteConnection of
                Nothing ->
                    span [] []

                Just deleteConnection ->
                    a
                        [ class "tool-button delete-connection"
                        , title "Delete connection"
                        , onLinkButtonClick deleteConnection
                        ]
                        [ i [ class "material-icons" ] [ text "close" ] ]

            , case config.selectCoto of
                Nothing ->
                    span [] []

                Just selectCoto ->
                    a
                        [ class "tool-button select-coto"
                        , title "Select this coto"
                        , onLinkButtonClick (selectCoto cotoId)
                        ]
                        [ i [ class "material-icons" ]
                            [ if isSelected (Just cotoId) context && not (Set.member cotoId context.deselecting) then
                                text "check_box"
                              else
                                text "check_box_outline_blank"
                            ]
                        ]
            ]
        ]


openTraversalButtonDiv : (CotoId -> msg) -> Maybe CotoId -> Graph -> Html msg
openTraversalButtonDiv buttonClick maybeCotoId graph =
    case maybeCotoId of
        Nothing ->
            div [] []

        Just cotoId ->
            if hasChildren cotoId graph then
                div [ class "sub-cotos-button" ]
                    [ a [ onLinkButtonClick (buttonClick cotoId) ]
                        [ i [ class "material-icons" ] [ text "arrow_forward" ] ]
                    ]
            else
                div [] []


subCotosDiv : Context -> Graph -> ElementId -> Coto -> Html Msg
subCotosDiv context graph parentElementId coto =
    case Dict.get coto.id graph.connections of
        Nothing -> div [] []
        Just connections ->
            div []
                [ div [ class "main-sub-border" ] []
                , connectionsDiv
                    context
                    graph
                    parentElementId
                    coto.id
                    connections
                ]


connectionsDiv : Context -> Graph -> ElementId -> CotoId -> List Connection -> Html Msg
connectionsDiv context graph parentElementId parentCotoId connections =
    Html.Keyed.node
        "div"
        [ class "sub-cotos" ]
        (List.filterMap
            (\conn ->
                case Dict.get conn.end graph.cotos of
                    Nothing -> Nothing  -- Missing the end node
                    Just coto -> Just
                        ( conn.key
                        , div
                            [ class "outbound-conn" ]
                            [ subCotoDiv
                                context
                                graph
                                parentElementId
                                parentCotoId
                                coto
                            ]
                        )
            )
            (List.reverse connections)
        )


subCotoDiv : Context -> Graph -> ElementId -> CotoId -> Coto -> Html Msg
subCotoDiv context graph parentElementId parentCotoId coto =
    let
        elementId = parentElementId ++ "-" ++ coto.id
    in
        div
            [ cotoClassList context elementId (Just coto.id) []
            , onClickWithoutPropagation (CotoClick elementId coto.id)
            , onMouseEnter (CotoMouseEnter elementId coto.id)
            , onMouseLeave (CotoMouseLeave elementId coto.id)
            ]
            [ div
                [ class "coto-inner" ]
                [ headerDiv CotonomaClick context.cotonoma graph coto
                , bodyDiv (Just ( parentCotoId, coto.id )) context graph coto
                , openTraversalButtonDiv OpenTraversal (Just coto.id) graph
                ]
            ]
