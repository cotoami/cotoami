module App.Views.Coto exposing (..)

import Set
import Html exposing (..)
import Html.Attributes exposing (..)
import Utils exposing (onLinkButtonClick)
import App.Types.Context exposing (Context, isSelected)
import App.Types.Coto exposing (Coto, ElementId, CotoId, Cotonoma, CotonomaKey, isPostedInCotonoma)
import App.Types.Graph exposing (Graph, pinned, hasChildren)


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
    , openTraversal : Maybe (CotoId -> msg)
    , cotonomaClick : CotonomaKey -> msg
    , deleteConnection : Maybe msg
    , markdown : String -> Html msg
    }


bodyDiv : Context -> Graph -> BodyConfig msg -> BodyModel -> Html msg
bodyDiv context graph config model =
    div [ class "coto-body" ]
        [ (case model.cotoId of
            Nothing ->
                span [] []

            Just cotoId ->
                cotoToolsSpan context graph config cotoId
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


cotoToolsSpan : Context -> Graph -> BodyConfig msg -> CotoId -> Html msg
cotoToolsSpan context graph config cotoId =
    span [ class "coto-tools" ]
        [ case config.selectCoto of
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
        , case config.openTraversal of
            Nothing ->
                span [] []

            Just openTraversal ->
                if App.Types.Graph.member cotoId graph then
                    a
                        [ class "tool-button traverse-coto"
                        , title "Traverse from this coto"
                        , onLinkButtonClick (openTraversal cotoId)
                        ]
                        [ i [ class "material-icons" ] [ text "arrow_forward" ] ]
                else
                    span [] []
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
