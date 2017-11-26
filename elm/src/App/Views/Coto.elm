module App.Views.Coto
    exposing
        ( Model
        , Config
        , defaultConfig
        , cotoClassList
        , abbreviate
        , headerDiv
        , bodyDivWithConfig
        , bodyDiv
        , toolButtonsSpan
        , subCotosEllipsisDiv
        , subCotosDiv
        , cotonomaLink
        , cotonomaLabel
        )

import Set
import Dict
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Html.Keyed
import Util.EventUtil exposing (onClickWithoutPropagation, onLinkButtonClick)
import Util.HtmlUtil exposing (faIcon, materialIcon)
import App.Markdown exposing (extractTextFromMarkdown)
import App.Types.Context exposing (Context, isSelected, orignatedHere, contentOpen)
import App.Types.Session exposing (Session)
import App.Types.Amishi exposing (Amishi)
import App.Types.Coto exposing (Coto, ElementId, CotoId, Cotonoma, CotonomaKey)
import App.Types.Graph exposing (Direction(..), Graph, Connection, pinned, hasChildren)
import App.Messages exposing (..)


type alias Model =
    { cotoId : Maybe CotoId
    , content : String
    , summary : Maybe String
    , amishi : Maybe Amishi
    , asCotonoma : Bool
    , cotonomaKey : Maybe CotonomaKey
    }


type alias Config =
    { openCotoMenu : Maybe Msg
    , selectCoto : Maybe (CotoId -> Msg)
    , pinCoto : Maybe (CotoId -> Msg)
    , openTraversal : Maybe (CotoId -> Msg)
    , confirmConnect : Maybe (CotoId -> Direction -> Msg)
    , deleteConnection : Maybe Msg
    , markdown : String -> Html Msg
    }


defaultConfig : Context -> Maybe ( Coto, Connection ) -> Coto -> Config
defaultConfig context maybeInbound coto =
    let
        deleteConnection =
            (Maybe.map2
                (\session ( parent, connection ) ->
                    ( ( parent.id, coto.id )
                    , isDisconnectable session parent connection coto
                    )
                )
                context.session
                maybeInbound
            )
                |> Maybe.andThen
                    (\( cotoIdPair, disconnectable ) ->
                        if disconnectable then
                            Just (ConfirmDeleteConnection cotoIdPair)
                        else
                            Nothing
                    )
    in
        { openCotoMenu = Just (OpenCotoMenuModal coto)
        , selectCoto = Just SelectCoto
        , pinCoto = Just PinCoto
        , openTraversal = Just OpenTraversal
        , confirmConnect = Just ConfirmConnect
        , deleteConnection = deleteConnection
        , markdown = App.Markdown.markdown
        }


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


abbreviate : { r | content : String, summary : Maybe String } -> String
abbreviate { content, summary } =
    let
        maxLength =
            200
    in
        Maybe.withDefault
            (extractTextFromMarkdown content
                |> List.head
                |> Maybe.withDefault ""
                |> (\text ->
                        (String.left maxLength text)
                            ++ (if String.length text > maxLength then
                                    "..."
                                else
                                    ""
                               )
                   )
            )
            summary


headerDiv : (CotonomaKey -> Msg) -> Context -> Graph -> Coto -> Html Msg
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
          else
            span [] []
        ]


isDisconnectable : Session -> Coto -> Connection -> Coto -> Bool
isDisconnectable session parent connection child =
    session.owner
        || (session.id == connection.amishiId)
        || ((Just session.id) == Maybe.map (\amishi -> amishi.id) parent.amishi)


bodyDivWithConfig : Context -> Graph -> ElementId -> Config -> Model -> Html Msg
bodyDivWithConfig context graph elementId config model =
    div [ class "coto-body" ]
        [ model.cotoId
            |> Maybe.map (toolButtonsSpan context graph config model.asCotonoma)
            |> Maybe.withDefault (span [] [])
        , model.cotonomaKey
            |> Maybe.map
                (\key ->
                    cotonomaLink CotonomaClick model.amishi key model.content
                )
            |> Maybe.withDefault (contentDiv context elementId config model)
        ]


contentDiv : Context -> ElementId -> Config -> Model -> Html Msg
contentDiv context elementId config model =
    model.summary
        |> Maybe.map
            (\summary ->
                div [ class "summary-and-content" ]
                    [ div
                        [ class "coto-summary" ]
                        [ a
                            [ class "tool-button toggle-coto-content"
                            , title "Toggle coto content"
                            , onLinkButtonClick (ToggleCotoContent elementId)
                            ]
                            [ faIcon
                                (if contentOpen elementId context then
                                    "angle-double-up"
                                 else
                                    "angle-double-down"
                                )
                                Nothing
                            ]
                        , span [ class "summary" ] [ text summary ]
                        ]
                    , div
                        [ classList
                            [ ( "coto-collapsible-content", True )
                            , ( "open", contentOpen elementId context )
                            ]
                        ]
                        [ config.markdown model.content ]
                    ]
            )
        |> Maybe.withDefault (config.markdown model.content)


bodyDiv : Context -> Graph -> Maybe ( Coto, Connection ) -> ElementId -> Coto -> Html Msg
bodyDiv context graph maybeConnection elementId coto =
    bodyDivWithConfig
        context
        graph
        elementId
        (defaultConfig context maybeConnection coto)
        { cotoId = Just coto.id
        , content = coto.content
        , summary = coto.summary
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


toolButtonsSpan : Context -> Graph -> Config -> Bool -> CotoId -> Html Msg
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
                            , title "Pin"
                            , onLinkButtonClick (pinCoto cotoId)
                            ]
                            [ faIcon "thumb-tack" Nothing ]
                )
      , config.deleteConnection
            |> Maybe.map
                (\deleteConnection ->
                    a
                        [ class "tool-button delete-connection"
                        , title "Disconnect"
                        , onLinkButtonClick deleteConnection
                        ]
                        [ faIcon "unlink" Nothing ]
                )
      , config.selectCoto
            |> Maybe.map
                (\selectCoto ->
                    a
                        [ class "tool-button select-coto"
                        , title "Select"
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
      , config.openCotoMenu
            |> Maybe.map
                (\openCotoMenu ->
                    a
                        [ class "tool-button open-coto-menu"
                        , title "More"
                        , onLinkButtonClick openCotoMenu
                        ]
                        [ materialIcon "more_horiz" Nothing ]
                )
      ]
        |> List.filterMap identity
        |> span [ class "default-buttons" ]
        |> Just
    ]
        |> List.filterMap identity
        |> span [ class "coto-tool-buttons" ]


subCotosEllipsisDiv : (CotoId -> Msg) -> Maybe CotoId -> Graph -> Html Msg
subCotosEllipsisDiv buttonClick maybeCotoId graph =
    case maybeCotoId of
        Nothing ->
            div [] []

        Just cotoId ->
            if hasChildren cotoId graph then
                div [ class "sub-cotos-button" ]
                    [ a [ onLinkButtonClick (buttonClick cotoId) ]
                        [ materialIcon "more_horiz" Nothing ]
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
                , bodyDiv context graph (Just connection) elementId coto
                , subCotosEllipsisDiv OpenTraversal (Just coto.id) graph
                ]
            ]


cotonomaLink : (CotonomaKey -> Msg) -> Maybe Amishi -> CotonomaKey -> String -> Html Msg
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
