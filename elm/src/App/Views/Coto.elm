module App.Views.Coto
    exposing
        ( cotoClassList
        , bodyDiv
        , bodyDivByCoto
        , ActionConfig
        , defaultActionConfig
        , headerDivWithDefaultConfig
        , headerDiv
        , toolButtonsSpan
        , subCotosEllipsisDiv
        , subCotosDiv
        , abbreviate
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



--
-- Body
--


type alias BodyModel r =
    { r
        | content : String
        , summary : Maybe String
        , amishi : Maybe Amishi
        , asCotonoma : Bool
        , cotonomaKey : Maybe CotonomaKey
    }


type alias Markdown =
    String -> Html Msg


bodyDiv : Context -> ElementId -> Markdown -> BodyModel r -> Html Msg
bodyDiv context elementId markdown model =
    div [ class "coto-body" ]
        [ model.cotonomaKey
            |> Maybe.map
                (\key ->
                    cotonomaLink CotonomaClick model.amishi key model.content
                )
            |> Maybe.withDefault (contentDiv context elementId markdown model)
        ]


bodyDivByCoto : Context -> ElementId -> Coto -> Html Msg
bodyDivByCoto context elementId coto =
    bodyDiv context elementId App.Markdown.markdown coto


contentDiv : Context -> ElementId -> Markdown -> BodyModel r -> Html Msg
contentDiv context elementId markdown model =
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
                        [ markdown model.content ]
                    ]
            )
        |> Maybe.withDefault (markdown model.content)



--
-- Header
--


type alias ActionConfig =
    { openCotoMenu : Maybe (Coto -> Msg)
    , selectCoto : Maybe (CotoId -> Msg)
    , pinCoto : Maybe (CotoId -> Msg)
    , editCoto : Maybe (Coto -> Msg)
    , addCoto : Maybe (Coto -> Msg)
    , openTraversal : Maybe (CotoId -> Msg)
    , confirmConnect : Maybe (CotoId -> Direction -> Msg)
    , deleteConnection : Maybe (( CotoId, CotoId ) -> Msg)
    }


defaultActionConfig : ActionConfig
defaultActionConfig =
    { openCotoMenu = Just OpenCotoMenuModal
    , selectCoto = Just SelectCoto
    , pinCoto = Just PinCoto
    , editCoto = Just OpenEditorModal
    , addCoto = Just OpenNewEditorModalWithSourceCoto
    , openTraversal = Just OpenTraversal
    , confirmConnect = Just ConfirmConnect
    , deleteConnection = Just ConfirmDeleteConnection
    }


headerDivWithDefaultConfig : Context -> Graph -> Maybe ( Coto, Connection ) -> Coto -> Html Msg
headerDivWithDefaultConfig context graph maybeInbound coto =
    headerDiv context graph maybeInbound defaultActionConfig coto


headerDiv : Context -> Graph -> Maybe ( Coto, Connection ) -> ActionConfig -> Coto -> Html Msg
headerDiv context graph maybeInbound config coto =
    div
        [ class "coto-header" ]
        [ toolButtonsSpan context graph maybeInbound config coto
        , coto.postedIn
            |> Maybe.map
                (\postedIn ->
                    if orignatedHere context coto then
                        span [] []
                    else
                        a
                            [ class "posted-in"
                            , href ("/cotonomas/" ++ postedIn.key)
                            , onLinkButtonClick (CotonomaClick postedIn.key)
                            ]
                            [ text postedIn.name ]
                )
            |> Maybe.withDefault (span [] [])
        , if pinned coto.id graph then
            faIcon "thumb-tack" (Just "pinned")
          else
            span [] []
        ]


toolButtonsSpan : Context -> Graph -> Maybe ( Coto, Connection ) -> ActionConfig -> Coto -> Html Msg
toolButtonsSpan context graph maybeInbound config coto =
    [ if List.isEmpty context.selection || isSelected (Just coto.id) context then
        Nothing
      else
        Maybe.map
            (\confirmConnect ->
                span [ class "connecting-buttons" ]
                    [ a
                        [ class "tool-button connect"
                        , title "Connect"
                        , onLinkButtonClick (confirmConnect coto.id Inbound)
                        ]
                        [ faIcon "link" Nothing ]
                    ]
            )
            config.confirmConnect
    , [ Maybe.map
            (\pinCoto ->
                if pinned coto.id graph then
                    span [] []
                else
                    a
                        [ class "tool-button pin-coto"
                        , title "Pin"
                        , onLinkButtonClick (pinCoto coto.id)
                        ]
                        [ faIcon "thumb-tack" Nothing ]
            )
            config.pinCoto
      , Maybe.map2
            (\editCoto session ->
                if App.Types.Coto.checkWritePermission session coto then
                    a
                        [ class "tool-button edit-coto"
                        , title "Edit"
                        , onLinkButtonClick (editCoto coto)
                        ]
                        [ materialIcon "edit" Nothing ]
                else
                    span [] []
            )
            config.editCoto
            context.session
      , Maybe.map
            (\addCoto ->
                a
                    [ class "tool-button add-coto"
                    , title "Create a connected Coto"
                    , onLinkButtonClick (addCoto coto)
                    ]
                    [ materialIcon "add" Nothing ]
            )
            config.addCoto
      , Maybe.map3
            (\deleteConnection session ( parent, connection ) ->
                if isDisconnectable session parent connection coto then
                    a
                        [ class "tool-button delete-connection"
                        , title "Disconnect"
                        , onLinkButtonClick (deleteConnection ( parent.id, coto.id ))
                        ]
                        [ faIcon "unlink" Nothing ]
                else
                    span [] []
            )
            config.deleteConnection
            context.session
            maybeInbound
      , Maybe.map
            (\selectCoto ->
                a
                    [ class "tool-button select-coto"
                    , title "Select"
                    , onLinkButtonClick (selectCoto coto.id)
                    ]
                    [ materialIcon
                        (if
                            isSelected (Just coto.id) context
                                && not (Set.member coto.id context.deselecting)
                         then
                            "check_box"
                         else
                            "check_box_outline_blank"
                        )
                        Nothing
                    ]
            )
            config.selectCoto
      , Maybe.map
            (\openCotoMenu ->
                a
                    [ class "tool-button open-coto-menu"
                    , title "More"
                    , onLinkButtonClick (openCotoMenu coto)
                    ]
                    [ materialIcon "more_horiz" Nothing ]
            )
            config.openCotoMenu
      ]
        |> List.filterMap identity
        |> span [ class "default-buttons" ]
        |> Just
    ]
        |> List.filterMap identity
        |> span [ class "coto-tool-buttons" ]


isDisconnectable : Session -> Coto -> Connection -> Coto -> Bool
isDisconnectable session parent connection child =
    session.owner
        || (session.id == connection.amishiId)
        || ((Just session.id) == Maybe.map (\amishi -> amishi.id) parent.amishi)



--
-- Sub cotos
--


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
                [ headerDiv context graph (Just connection) defaultActionConfig coto
                , bodyDivByCoto context elementId coto
                , subCotosEllipsisDiv OpenTraversal (Just coto.id) graph
                ]
            ]



--
-- Misc
--


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
