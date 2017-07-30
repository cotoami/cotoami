module Components.Coto exposing (..)

import Set
import Html exposing (..)
import Html.Attributes exposing (..)
import Utils exposing (onClickWithoutPropagation)
import App.Types.Context exposing (Context, isSelected)
import App.Types.Coto exposing (Coto, CotoId, Cotonoma, CotonomaKey, isPostedInCotonoma)
import App.Graph exposing (Graph, pinned, hasChildren)


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
                        , onClickWithoutPropagation (cotonomaClick postedIn.key)
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
          else if App.Graph.member coto.id graph then
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
    , cotonomaKey : CotonomaKey
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
            div [ class "coto-as-cotonoma" ]
                [ a
                    [ href ("/cotonomas/" ++ model.cotonomaKey)
                    , onClickWithoutPropagation (config.cotonomaClick model.cotonomaKey)
                    ]
                    [ i [ class "material-icons" ] [ text "exit_to_app" ]
                    , span [ class "cotonoma-name" ] [ text model.content ]
                    ]
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
                    , title "Select coto"
                    , onClickWithoutPropagation (selectCoto cotoId)
                    ]
                    [ i [ class "material-icons" ]
                        [ if isSelected cotoId context && not (Set.member cotoId context.deselecting) then
                            text "check_box"
                          else
                            text "check_box_outline_blank"
                        ]
                    ]
        , case config.openTraversal of
            Nothing ->
                span [] []

            Just openTraversal ->
                if App.Graph.member cotoId graph then
                    a
                        [ class "tool-button traverse-coto"
                        , title "Open coto traversal"
                        , onClickWithoutPropagation (openTraversal cotoId)
                        ]
                        [ i [ class "material-icons" ] [ text "exit_to_app" ] ]
                else
                    span [] []
        , case config.openCoto of
            Nothing ->
                span [] []

            Just openCoto ->
                a
                    [ class "tool-button open-coto"
                    , title "Open coto view"
                    , onClickWithoutPropagation openCoto
                    ]
                    [ i [ class "material-icons" ] [ text "settings" ] ]
        , case config.deleteConnection of
            Nothing ->
                span [] []

            Just deleteConnection ->
                a
                    [ class "tool-button delete-connection"
                    , title "Delete connection"
                    , onClickWithoutPropagation deleteConnection
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
                    [ a [ onClickWithoutPropagation (buttonClick cotoId) ]
                        [ i [ class "material-icons" ] [ text "more_horiz" ] ]
                    ]
            else
                div [] []
