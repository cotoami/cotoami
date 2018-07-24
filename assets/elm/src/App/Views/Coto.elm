module App.Views.Coto
    exposing
        ( cotoClassList
        , bodyDiv
        , bodyDivByCoto
        , InboundConnection
        , ActionConfig
        , defaultActionConfig
        , headerDivWithDefaultConfig
        , headerDiv
        , toolButtonsSpan
        , parentsDiv
        , subCotosButtonDiv
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
import App.Types.Graph exposing (Direction(..), Graph, Connection)
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
        , asCotonoma : Maybe Cotonoma
    }


type alias Markdown =
    String -> Html Msg


bodyDiv : Context -> ElementId -> Markdown -> BodyModel r -> Html Msg
bodyDiv context elementId markdown model =
    div [ class "coto-body" ]
        [ model.asCotonoma
            |> Maybe.map (cotonomaLink CotonomaClick model.amishi)
            |> Maybe.withDefault
                (if App.Types.Context.inReorderMode elementId context then
                    contentDivInReorder model
                 else
                    contentDiv context elementId markdown model
                )
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


contentDivInReorder : BodyModel r -> Html Msg
contentDivInReorder model =
    div [ class "content-in-reorder" ]
        [ text (abbreviate model)
        ]



--
-- Header
--


type alias InboundConnection =
    { parent : Maybe Coto
    , connection : Connection
    , siblings : Int
    , index : Int
    }


type alias ActionConfig =
    { openCotoMenu : Maybe (Coto -> Msg)
    , selectCoto : Maybe (CotoId -> Msg)
    , pinCoto : Maybe (CotoId -> Msg)
    , editCoto : Maybe (Coto -> Msg)
    , addCoto : Maybe (Coto -> Msg)
    , openTraversal : Maybe (CotoId -> Msg)
    , confirmConnect : Maybe (CotoId -> Direction -> Msg)
    , toggleReorderMode : Maybe (ElementId -> Msg)
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
    , toggleReorderMode = Nothing
    , deleteConnection = Just ConfirmDeleteConnection
    }


headerDivWithDefaultConfig : Context -> Graph -> Maybe InboundConnection -> ElementId -> Coto -> Html Msg
headerDivWithDefaultConfig context graph maybeInbound elementId coto =
    headerDiv context graph maybeInbound defaultActionConfig elementId coto


headerDiv : Context -> Graph -> Maybe InboundConnection -> ActionConfig -> ElementId -> Coto -> Html Msg
headerDiv context graph maybeInbound config elementId coto =
    div
        [ class "coto-header" ]
        [ if App.Types.Context.inReorderMode elementId context then
            maybeInbound
                |> Maybe.map
                    (\inbound -> reorderToolButtonsSpan context inbound elementId)
                |> Maybe.withDefault
                    (toolButtonsSpan context graph maybeInbound config elementId coto)
          else
            toolButtonsSpan context graph maybeInbound config elementId coto
        , coto.postedIn
            |> Maybe.map
                (\postedIn ->
                    if orignatedHere context coto then
                        Util.HtmlUtil.none
                    else
                        a
                            [ class "posted-in"
                            , href ("/cotonomas/" ++ postedIn.key)
                            , onLinkButtonClick (CotonomaClick postedIn.key)
                            ]
                            [ text postedIn.name ]
                )
            |> Maybe.withDefault Util.HtmlUtil.none
        , if App.Types.Graph.pinned coto.id graph then
            faIcon "thumb-tack" (Just "pinned")
          else
            Util.HtmlUtil.none
        ]


toolButtonsSpan :
    Context
    -> Graph
    -> Maybe InboundConnection
    -> ActionConfig
    -> ElementId
    -> Coto
    -> Html Msg
toolButtonsSpan context graph maybeInbound config elementId coto =
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
                    , span [ class "border" ] []
                    ]
            )
            config.confirmConnect
    , maybeInbound
        |> Maybe.andThen
            (\inbound ->
                subCotoButtonsSpan context graph inbound config elementId coto
            )
    , [ Maybe.map
            (\pinCoto ->
                if App.Types.Graph.pinned coto.id graph then
                    Util.HtmlUtil.none
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
                    Util.HtmlUtil.none
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


subCotoButtonsSpan :
    Context
    -> Graph
    -> InboundConnection
    -> ActionConfig
    -> ElementId
    -> Coto
    -> Maybe (Html Msg)
subCotoButtonsSpan context graph inbound config elementId coto =
    [ (Maybe.map3
        (\deleteConnection session parent ->
            if isDisconnectable session parent inbound.connection coto then
                Just <|
                    a
                        [ class "tool-button delete-connection"
                        , title "Disconnect"
                        , onLinkButtonClick (deleteConnection ( parent.id, coto.id ))
                        ]
                        [ faIcon "unlink" Nothing ]
            else
                Nothing
        )
        config.deleteConnection
        context.session
        inbound.parent
      )
        |> Maybe.withDefault Nothing
    , (Maybe.map2
        (\toggleReorderMode session ->
            if isReorderble context session inbound coto then
                Just <|
                    a
                        [ class "tool-button toggle-reorder-mode"
                        , title "Reorder"
                        , onLinkButtonClick (toggleReorderMode elementId)
                        ]
                        [ faIcon "sort" Nothing ]
            else
                Nothing
        )
        config.toggleReorderMode
        context.session
      )
        |> Maybe.withDefault Nothing
    ]
        |> List.filterMap identity
        |> (\buttons ->
                if List.isEmpty buttons then
                    Nothing
                else
                    Just <| buttons ++ [ span [ class "border" ] [] ]
           )
        |> Maybe.map (span [ class "sub-coto-buttons" ])


isDisconnectable : Session -> Coto -> Connection -> Coto -> Bool
isDisconnectable session parent connection child =
    session.owner
        || (session.id == connection.amishiId)
        || ((Just session.id) == Maybe.map (\amishi -> amishi.id) parent.amishi)


isReorderble : Context -> Session -> InboundConnection -> Coto -> Bool
isReorderble context session inbound child =
    if inbound.siblings < 2 then
        False
    else if session.owner then
        True
    else
        inbound.parent
            |> Maybe.map
                (\parent ->
                    Just session.id
                        == (parent.amishi
                                |> Maybe.map (\amishi -> amishi.id)
                           )
                )
            |> Maybe.withDefault
                (context.cotonoma
                    |> Maybe.map
                        (\cotonoma ->
                            Just session.id
                                == (cotonoma.owner
                                        |> Maybe.map (\owner -> owner.id)
                                   )
                        )
                    |> Maybe.withDefault True
                )


reorderToolButtonsSpan : Context -> InboundConnection -> ElementId -> Html Msg
reorderToolButtonsSpan context inbound elementId =
    let
        maybeParentId =
            inbound.parent |> Maybe.map (\parent -> parent.id)

        index =
            inbound.index

        isFirst =
            inbound.index == 0

        isLast =
            inbound.index == (inbound.siblings - 1)
    in
        span [ class "reorder-tool-buttons" ]
            [ a
                [ classList
                    [ ( "tool-button", True )
                    , ( "move-to-top", True )
                    , ( "disabled", isFirst )
                    ]
                , title "Move to the top"
                , onLinkButtonClick (MoveToFirst maybeParentId index)
                ]
                [ materialIcon "skip_previous" Nothing ]
            , a
                [ classList
                    [ ( "tool-button", True )
                    , ( "move-up", True )
                    , ( "disabled", isFirst )
                    ]
                , title "Move up"
                , onLinkButtonClick (SwapOrder maybeParentId index (index - 1))
                ]
                [ materialIcon "play_arrow" Nothing ]
            , a
                [ classList
                    [ ( "tool-button", True )
                    , ( "move-down", True )
                    , ( "disabled", isLast )
                    ]
                , title "Move down"
                , onLinkButtonClick (SwapOrder maybeParentId index (index + 1))
                ]
                [ materialIcon "play_arrow" Nothing ]
            , a
                [ classList
                    [ ( "tool-button", True )
                    , ( "move-to-bottom", True )
                    , ( "disabled", isLast )
                    ]
                , title "Move to the bottom"
                , onLinkButtonClick (MoveToLast maybeParentId index)
                ]
                [ materialIcon "skip_next" Nothing ]
            , a
                [ class "tool-button close"
                , title "Close reorder tools"
                , onLinkButtonClick (ToggleReorderMode elementId)
                ]
                [ materialIcon "close" Nothing ]
            ]



--
-- Parents
--


parentsDiv : Graph -> Maybe CotoId -> CotoId -> Html Msg
parentsDiv graph exclude childId =
    let
        parents =
            App.Types.Graph.getParents childId graph
                |> List.filter (\parent -> (Just parent.id) /= exclude)
    in
        if List.isEmpty parents then
            Util.HtmlUtil.none
        else
            div [ class "parents" ]
                (List.map
                    (\parent ->
                        div
                            [ class "parent"
                            , onClick (OpenTraversal parent.id)
                            ]
                            [ text (abbreviate parent) ]
                    )
                    parents
                )



--
-- Sub cotos
--


subCotosButtonDiv : Graph -> Maybe String -> Maybe CotoId -> Html Msg
subCotosButtonDiv graph maybeIconName maybeCotoId =
    maybeCotoId
        |> Maybe.map
            (\cotoId ->
                if App.Types.Graph.hasChildren cotoId graph then
                    div [ class "sub-cotos-button" ]
                        [ a
                            [ class "tool-button"
                            , onLinkButtonClick (OpenTraversal cotoId)
                            ]
                            [ materialIcon
                                (Maybe.withDefault "more_horiz" maybeIconName)
                                Nothing
                            ]
                        ]
                else
                    Util.HtmlUtil.none
            )
        |> Maybe.withDefault Util.HtmlUtil.none


subCotosDiv : Context -> Graph -> ElementId -> Coto -> Html Msg
subCotosDiv context graph parentElementId coto =
    if App.Types.Context.inReorderMode parentElementId context then
        div [] []
    else
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
            |> Maybe.withDefault Util.HtmlUtil.none


connectionsDiv : Context -> Graph -> ElementId -> Coto -> List Connection -> Html Msg
connectionsDiv context graph parentElementId parentCoto connections =
    connections
        |> List.reverse
        |> List.indexedMap
            (\index connection ->
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
                                    (InboundConnection
                                        (Just parentCoto)
                                        connection
                                        (List.length connections)
                                        index
                                    )
                                    coto
                                ]
                            )
                        )
                    |> Maybe.withDefault
                        ( connection.key, Util.HtmlUtil.none )
            )
        |> Html.Keyed.node "div" [ class "sub-cotos" ]


subCotoDiv : Context -> Graph -> ElementId -> InboundConnection -> Coto -> Html Msg
subCotoDiv context graph parentElementId inbound coto =
    let
        elementId =
            parentElementId ++ "-" ++ coto.id

        maybeParentId =
            inbound.parent |> Maybe.map (\parent -> parent.id)
    in
        div
            [ cotoClassList context elementId (Just coto.id) []
            , onClickWithoutPropagation (CotoClick elementId coto.id)
            , onMouseEnter (CotoMouseEnter elementId coto.id)
            , onMouseLeave (CotoMouseLeave elementId coto.id)
            ]
            [ div
                [ class "coto-inner" ]
                [ headerDiv
                    context
                    graph
                    (Just inbound)
                    { defaultActionConfig
                        | toggleReorderMode = Just ToggleReorderMode
                    }
                    elementId
                    coto
                , parentsDiv graph maybeParentId coto.id
                , div [ class "sub-coto-body" ]
                    [ bodyDivByCoto context elementId coto
                    , subCotosButtonDiv graph (Just "more_vert") (Just coto.id)
                    ]
                ]
            ]



--
-- Misc
--


abbreviate : { r | content : String, summary : Maybe String } -> String
abbreviate { content, summary } =
    let
        maxLength =
            App.Types.Coto.summaryMaxlength
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


cotonomaLink : (CotonomaKey -> Msg) -> Maybe Amishi -> Cotonoma -> Html Msg
cotonomaLink cotonomaClick maybeOwner cotonoma =
    a
        [ class "cotonoma-link"
        , href ("/cotonomas/" ++ cotonoma.key)
        , onLinkButtonClick (cotonomaClick cotonoma.key)
        ]
        [ cotonomaLabel maybeOwner cotonoma ]


cotonomaLabel : Maybe Amishi -> Cotonoma -> Html msg
cotonomaLabel maybeOwner cotonoma =
    span
        [ class "cotonoma-label" ]
        [ maybeOwner
            |> Maybe.map (\owner -> img [ class "avatar", src owner.avatarUrl ] [])
            |> Maybe.withDefault Util.HtmlUtil.none
        , span [ class "cotonoma-name" ] [ text cotonoma.name ]
        , if cotonoma.shared then
            span [ class "shared" ] [ materialIcon "people" Nothing ]
          else
            Util.HtmlUtil.none
        ]
