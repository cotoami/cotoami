module App.Views.Coto
    exposing
        ( cotoClassList
        , bodyDiv
        , bodyDivByCoto
        , headerDiv
        , parentsDiv
        , subCotosButtonDiv
        , subCotosDiv
        , abbreviate
        , cotonomaLink
        , cotonomaLabel
        )

import Dict
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Html.Keyed
import Utils.EventUtil exposing (onClickWithoutPropagation, onLinkButtonClick)
import Utils.HtmlUtil exposing (faIcon, materialIcon)
import App.Markdown exposing (extractTextFromMarkdown)
import App.Types.Amishi exposing (Amishi)
import App.Types.Coto exposing (Coto, ElementId, CotoId, Cotonoma, CotonomaKey)
import App.Types.Graph exposing (Direction(..), Graph, Connection, InboundConnection)
import App.Submodels.Context exposing (Context)
import App.Messages exposing (..)
import App.Views.CotoToolbar


cotoClassList : Context a -> ElementId -> Maybe CotoId -> List ( String, Bool ) -> Attribute msg
cotoClassList context elementId maybeCotoId additionalClasses =
    classList
        ([ ( "coto", True )
         , ( "selectable", True )
         , ( "element-focus", Just elementId == context.elementFocus )
         , ( "coto-focus"
           , Maybe.map2 (==) maybeCotoId context.cotoFocus
                |> Maybe.withDefault False
           )
         , ( "selected", App.Submodels.Context.isSelected maybeCotoId context )
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


bodyDiv : Context a -> ElementId -> Markdown -> BodyModel r -> Html Msg
bodyDiv context elementId markdown model =
    div [ class "coto-body" ]
        [ model.asCotonoma
            |> Maybe.map (cotonomaLink context CotonomaClick model.amishi)
            |> Maybe.withDefault
                (if App.Submodels.Context.inReorderMode elementId context then
                    contentDivInReorder model
                 else
                    contentDiv context elementId markdown model
                )
        ]


bodyDivByCoto : Context a -> ElementId -> Coto -> Html Msg
bodyDivByCoto context elementId coto =
    bodyDiv context elementId App.Markdown.markdown coto


contentDiv : Context a -> ElementId -> Markdown -> BodyModel r -> Html Msg
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
                                (if App.Submodels.Context.contentOpen elementId context then
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
                            , ( "open", App.Submodels.Context.contentOpen elementId context )
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


headerDiv : Context a -> Graph -> Maybe InboundConnection -> ElementId -> Coto -> Html Msg
headerDiv context graph maybeInbound elementId coto =
    div
        [ class "coto-header" ]
        [ if App.Submodels.Context.inReorderMode elementId context then
            maybeInbound
                |> Maybe.map
                    (\inbound -> reorderToolButtonsSpan context inbound elementId)
                |> Maybe.withDefault
                    Utils.HtmlUtil.none
          else
            context.session
                |> Maybe.map
                    (\session ->
                        App.Views.CotoToolbar.view
                            context
                            session
                            graph
                            maybeInbound
                            elementId
                            coto
                    )
                |> Maybe.withDefault
                    Utils.HtmlUtil.none
        , coto.postedIn
            |> Maybe.map
                (\postedIn ->
                    if App.Submodels.Context.orignatedHere context coto then
                        Utils.HtmlUtil.none
                    else
                        a
                            [ class "posted-in"
                            , href ("/cotonomas/" ++ postedIn.key)
                            , onLinkButtonClick (CotonomaClick postedIn.key)
                            ]
                            [ text postedIn.name ]
                )
            |> Maybe.withDefault Utils.HtmlUtil.none
        , if App.Types.Graph.pinned coto.id graph then
            faIcon "thumb-tack" (Just "pinned")
          else
            Utils.HtmlUtil.none
        ]


reorderToolButtonsSpan : Context a -> InboundConnection -> ElementId -> Html Msg
reorderToolButtonsSpan context inbound elementId =
    let
        maybeParentId =
            Maybe.map (.id) inbound.parent

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
            Utils.HtmlUtil.none
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
                    Utils.HtmlUtil.none
            )
        |> Maybe.withDefault Utils.HtmlUtil.none


subCotosDiv : Context a -> Graph -> ElementId -> Coto -> Html Msg
subCotosDiv context graph parentElementId coto =
    if App.Submodels.Context.inReorderMode parentElementId context then
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
            |> Maybe.withDefault Utils.HtmlUtil.none


connectionsDiv : Context a -> Graph -> ElementId -> Coto -> List Connection -> Html Msg
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
                        ( connection.key, Utils.HtmlUtil.none )
            )
        |> Html.Keyed.node "div" [ class "sub-cotos" ]


subCotoDiv : Context a -> Graph -> ElementId -> InboundConnection -> Coto -> Html Msg
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


cotonomaLink : Context a -> (CotonomaKey -> Msg) -> Maybe Amishi -> Cotonoma -> Html Msg
cotonomaLink context cotonomaClick maybeOwner cotonoma =
    if isCotonomaAccessible context maybeOwner cotonoma then
        a
            [ class "cotonoma-link"
            , href ("/cotonomas/" ++ cotonoma.key)
            , onLinkButtonClick (cotonomaClick cotonoma.key)
            ]
            [ cotonomaLabel maybeOwner cotonoma ]
    else
        span [ class "not-accessible" ]
            [ cotonomaLabel maybeOwner cotonoma
            , span [ class "private", title "Private" ]
                [ materialIcon "lock" Nothing ]
            ]


isCotonomaAccessible : Context a -> Maybe Amishi -> Cotonoma -> Bool
isCotonomaAccessible context maybeOwner cotonoma =
    if cotonoma.shared then
        True
    else
        (Maybe.map2
            (\session owner -> session.amishi.id == owner.id)
            context.session
            maybeOwner
        )
            |> Maybe.withDefault False


cotonomaLabel : Maybe Amishi -> Cotonoma -> Html msg
cotonomaLabel maybeOwner cotonoma =
    span
        [ class "cotonoma-label" ]
        [ maybeOwner
            |> Maybe.map (\owner -> img [ class "avatar", src owner.avatarUrl ] [])
            |> Maybe.withDefault Utils.HtmlUtil.none
        , span [ class "cotonoma-name" ] [ text cotonoma.name ]
        , if cotonoma.shared then
            span [ class "shared", title "Shared" ]
                [ materialIcon "people" Nothing ]
          else
            Utils.HtmlUtil.none
        ]
