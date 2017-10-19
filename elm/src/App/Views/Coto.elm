module App.Views.Coto exposing (..)

import Set
import Dict
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Html.Keyed
import Util.EventUtil exposing (onClickWithoutPropagation, onLinkButtonClick)
import Util.HtmlUtil exposing (faIcon, materialIcon)
import App.Markdown exposing (extractTextFromMarkdown)
import App.Types.Context exposing (Context, isSelected, orignatedHere)
import App.Types.Session exposing (Session)
import App.Types.Amishi exposing (Amishi)
import App.Types.Coto exposing (Coto, ElementId, CotoId, Cotonoma, CotonomaKey)
import App.Types.Graph exposing (Direction(..), Graph, Connection, pinned, hasChildren)
import App.Messages exposing (..)


cotoClassList : Context -> ElementId -> Maybe CotoId -> List ( String, Bool ) -> Attribute msg
cotoClassList context elementId maybeCotoId additionalClasses =
    classList
        ([ ( "coto", True )
         , ( "selectable", True )
         , ( "element-focus", Just elementId == context.elementFocus )
         , ( "coto-focus"
           , Maybe.map2 (==) maybeCotoId context.cotoFocus
                |> Maybe.withDefault False
           )
         , ( "selected", isSelected maybeCotoId context )
         ]
            ++ additionalClasses
        )


headline : { r | content : String } -> String
headline { content } =
    extractTextFromMarkdown content
        |> List.head
        |> Maybe.withDefault ""
        |> String.left 100


headerDiv : (CotonomaKey -> msg) -> Context -> Graph -> Coto -> Html msg
headerDiv cotonomaClick context graph coto =
    div
        [ class "coto-header" ]
        [ coto.postedIn
            |> Maybe.map
                (\postedIn ->
                    if orignatedHere context coto then
                        span [] []
                    else
                        a
                            [ class "posted-in"
                            , href ("/cotonomas/" ++ postedIn.key)
                            , onLinkButtonClick (cotonomaClick postedIn.key)
                            ]
                            [ text postedIn.name ]
                )
            |> Maybe.withDefault (span [] [])
        , if pinned coto.id graph then
            faIcon "thumb-tack" (Just "pinned")
          else if App.Types.Graph.member coto.id graph then
            faIcon "share-alt" (Just "connected")
          else
            span [] []
        ]


type alias BodyModel =
    { cotoId : Maybe CotoId
    , content : String
    , amishi : Maybe Amishi
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


defaultBodyConfig : Context -> Maybe ( Coto, Connection ) -> Coto -> BodyConfig Msg
defaultBodyConfig context maybeConnection coto =
    let
        deleteConnection =
            (Maybe.map2
                (\session ( parent, connection ) ->
                    ( ( parent.id, coto.id )
                    , isDisconnectable session parent connection coto
                    )
                )
                context.session
                maybeConnection
            )
                |> Maybe.andThen
                    (\( cotoIdPair, disconnectable ) ->
                        if disconnectable then
                            Just (ConfirmDeleteConnection cotoIdPair)
                        else
                            Nothing
                    )
    in
        { openCoto = Just (OpenCotoModal coto)
        , selectCoto = Just SelectCoto
        , pinCoto = Just PinCoto
        , openTraversal = Just OpenTraversal
        , cotonomaClick = CotonomaClick
        , confirmConnect = Just ConfirmConnect
        , deleteConnection = deleteConnection
        , markdown = App.Markdown.markdown
        }


isDisconnectable : Session -> Coto -> Connection -> Coto -> Bool
isDisconnectable session parent connection child =
    session.owner
        || (session.id == connection.amishiId)
        || ((Just session.id) == Maybe.map (\amishi -> amishi.id) parent.amishi)


bodyDivWithConfig : Context -> Graph -> BodyConfig msg -> BodyModel -> Html msg
bodyDivWithConfig context graph config model =
    div [ class "coto-body" ]
        [ model.cotoId
            |> Maybe.map (toolButtonsSpan context graph config model.asCotonoma)
            |> Maybe.withDefault (span [] [])
        , model.cotonomaKey
            |> Maybe.map
                (\cotonomaKey ->
                    cotonomaLink config.cotonomaClick model.amishi cotonomaKey model.content
                )
            |> Maybe.withDefault (config.markdown model.content)
        ]


bodyDiv : Context -> Graph -> Maybe ( Coto, Connection ) -> Coto -> Html Msg
bodyDiv context graph maybeConnection coto =
    bodyDivWithConfig
        context
        graph
        (defaultBodyConfig context maybeConnection coto)
        { cotoId = Just coto.id
        , content = coto.content
        , amishi = coto.amishi
        , asCotonoma = coto.asCotonoma
        , cotonomaKey = coto.cotonomaKey
        }


connectInboundIcon : Html msg
connectInboundIcon =
    faIcon "sign-in" Nothing


connectOutboundIcon : Html msg
connectOutboundIcon =
    faIcon "sign-out" Nothing


toolButtonsSpan : Context -> Graph -> BodyConfig msg -> Bool -> CotoId -> Html msg
toolButtonsSpan context graph config asCotonoma cotoId =
    [ if List.isEmpty context.selection || isSelected (Just cotoId) context then
        Nothing
      else
        config.confirmConnect
            |> Maybe.map
                (\confirmConnect ->
                    span [ class "connecting-buttons" ]
                        [ a
                            [ class "tool-button connect"
                            , title "Connect"
                            , onLinkButtonClick (confirmConnect cotoId Inbound)
                            ]
                            [ faIcon "link" Nothing ]
                        ]
                )
    , [ config.pinCoto
            |> Maybe.map
                (\pinCoto ->
                    if pinned cotoId graph then
                        span [] []
                    else
                        a
                            [ class "tool-button pin-coto"
                            , title "Pin this coto"
                            , onLinkButtonClick (pinCoto cotoId)
                            ]
                            [ faIcon "thumb-tack" Nothing ]
                )
      , config.openTraversal
            |> Maybe.map
                (\openTraversal ->
                    a
                        [ class "tool-button traverse-coto"
                        , title "Traverse from this coto"
                        , onLinkButtonClick (openTraversal cotoId)
                        ]
                        [ materialIcon "arrow_forward" Nothing ]
                )
      , config.openCoto
            |> Maybe.map
                (\openCoto ->
                    a
                        [ class "tool-button open-coto"
                        , title "Open coto view"
                        , onLinkButtonClick openCoto
                        ]
                        [ materialIcon "settings" Nothing ]
                )
      , config.deleteConnection
            |> Maybe.map
                (\deleteConnection ->
                    a
                        [ class "tool-button delete-connection"
                        , title "Delete connection"
                        , onLinkButtonClick deleteConnection
                        ]
                        [ faIcon "unlink" Nothing ]
                )
      , config.selectCoto
            |> Maybe.map
                (\selectCoto ->
                    a
                        [ class "tool-button select-coto"
                        , title "Select this coto"
                        , onLinkButtonClick (selectCoto cotoId)
                        ]
                        [ materialIcon
                            (if
                                isSelected (Just cotoId) context
                                    && not (Set.member cotoId context.deselecting)
                             then
                                "check_box"
                             else
                                "check_box_outline_blank"
                            )
                            Nothing
                        ]
                )
      ]
        |> List.filterMap identity
        |> span [ class "default-buttons" ]
        |> Just
    ]
        |> List.filterMap identity
        |> span [ class "coto-tool-buttons" ]


openTraversalButtonDiv : (CotoId -> msg) -> Maybe CotoId -> Graph -> Html msg
openTraversalButtonDiv buttonClick maybeCotoId graph =
    case maybeCotoId of
        Nothing ->
            div [] []

        Just cotoId ->
            if hasChildren cotoId graph then
                div [ class "sub-cotos-button" ]
                    [ a [ onLinkButtonClick (buttonClick cotoId) ]
                        [ materialIcon "arrow_forward" Nothing ]
                    ]
            else
                div [] []


subCotosDiv : Context -> Graph -> ElementId -> Coto -> Html Msg
subCotosDiv context graph parentElementId coto =
    graph.connections
        |> Dict.get coto.id
        |> Maybe.map
            (\connections ->
                div []
                    [ div [ class "main-sub-border" ] []
                    , connectionsDiv
                        context
                        graph
                        parentElementId
                        coto
                        connections
                    ]
            )
        |> Maybe.withDefault (div [] [])


connectionsDiv : Context -> Graph -> ElementId -> Coto -> List Connection -> Html Msg
connectionsDiv context graph parentElementId parentCoto connections =
    connections
        |> List.reverse
        |> List.filterMap
            (\connection ->
                graph.cotos
                    |> Dict.get connection.end
                    |> Maybe.map
                        (\coto ->
                            ( connection.key
                            , div
                                [ class "outbound-conn" ]
                                [ subCotoDiv
                                    context
                                    graph
                                    parentElementId
                                    ( parentCoto, connection )
                                    coto
                                ]
                            )
                        )
            )
        |> Html.Keyed.node "div" [ class "sub-cotos" ]


subCotoDiv : Context -> Graph -> ElementId -> ( Coto, Connection ) -> Coto -> Html Msg
subCotoDiv context graph parentElementId connection coto =
    let
        elementId =
            parentElementId ++ "-" ++ coto.id
    in
        div
            [ cotoClassList context elementId (Just coto.id) []
            , onClickWithoutPropagation (CotoClick elementId coto.id)
            , onMouseEnter (CotoMouseEnter elementId coto.id)
            , onMouseLeave (CotoMouseLeave elementId coto.id)
            ]
            [ div
                [ class "coto-inner" ]
                [ headerDiv CotonomaClick context graph coto
                , bodyDiv context graph (Just connection) coto
                , openTraversalButtonDiv OpenTraversal (Just coto.id) graph
                ]
            ]


cotonomaLink : (CotonomaKey -> msg) -> Maybe Amishi -> CotonomaKey -> String -> Html msg
cotonomaLink cotonomaClick maybeOwner cotonomaKey name =
    a
        [ class "cotonoma-link"
        , href ("/cotonomas/" ++ cotonomaKey)
        , onLinkButtonClick (cotonomaClick cotonomaKey)
        ]
        [ cotonomaLabel maybeOwner name ]


cotonomaLabel : Maybe Amishi -> String -> Html msg
cotonomaLabel maybeOwner name =
    span
        [ class "cotonoma-label" ]
        [ maybeOwner
            |> Maybe.map (\owner -> img [ class "avatar", src owner.avatarUrl ] [])
            |> Maybe.withDefault (span [] [])
        , span [ class "cotonoma-name" ] [ text name ]
        ]
