module App.Views.Coto exposing
    ( abbreviate
    , bodyDiv
    , bodyDivByCoto
    , cotoClassList
    , cotonomaLabel
    , cotonomaLink
    , headerDiv
    , linkingPhraseDiv
    , openTraversalButton
    , openTraversalButtonDiv
    , parentsDiv
    , subCotosDiv
    )

import App.Markdown exposing (extractTextFromMarkdown)
import App.Messages exposing (Msg)
import App.Submodels.Context exposing (Context)
import App.Submodels.CotoSelection
import App.Types.Amishi exposing (Amishi)
import App.Types.Connection exposing (Connection, Direction(..), InboundConnection, Reordering(..))
import App.Types.Coto exposing (Coto, CotoId, Cotonoma, CotonomaKey, ElementId)
import App.Types.Graph exposing (Graph)
import App.Views.CotoToolbar
import App.Views.Reorder
import Dict
import Exts.Maybe exposing (isJust)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Html.Keyed
import Utils.EventUtil exposing (onClickWithoutPropagation, onLinkButtonClick)
import Utils.HtmlUtil exposing (faIcon, materialIcon)


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
         , ( "selected"
           , maybeCotoId
                |> Maybe.map
                    (\cotoId ->
                        App.Submodels.CotoSelection.isSelected cotoId context
                    )
                |> Maybe.withDefault False
           )
         , ( "focused-in-reordering"
           , App.Submodels.Context.isTriggerElementInReordering elementId context
           )
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


bodyDiv : Context a -> Maybe InboundConnection -> ElementId -> Markdown -> BodyModel r -> Html Msg
bodyDiv context maybeInbound elementId markdown model =
    div [ class "coto-body" ]
        [ model.asCotonoma
            |> Maybe.map (cotonomaLink context App.Messages.CotonomaClick model.amishi)
            |> Maybe.withDefault
                (if App.Types.Connection.inReordering maybeInbound then
                    div [ class "content-in-reorder" ] [ text (abbreviate model) ]

                 else
                    contentDiv context elementId markdown model
                )
        ]


bodyDivByCoto : Context a -> Maybe InboundConnection -> ElementId -> Coto -> Html Msg
bodyDivByCoto context maybeInbound elementId coto =
    div [ class "coto-body" ]
        [ coto.asCotonoma
            |> Maybe.map (cotonomaLink context App.Messages.CotonomaClick coto.amishi)
            |> Maybe.withDefault
                (if App.Types.Connection.inReordering maybeInbound then
                    div [ class "content-in-reorder" ] [ text (abbreviate coto) ]

                 else
                    App.Types.Coto.toTopic coto
                        |> Maybe.map
                            (\_ ->
                                div [ class "topic-coto-body" ]
                                    [ img [ class "topic-icon", src "/images/topic.svg" ] []
                                    , contentDiv context elementId App.Markdown.markdown coto
                                    ]
                            )
                        |> Maybe.withDefault
                            (contentDiv context elementId App.Markdown.markdown coto)
                )
        ]


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
                            , onLinkButtonClick (App.Messages.ToggleCotoContent elementId)
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



--
-- Header
--


headerDiv : Context a -> Maybe InboundConnection -> ElementId -> Coto -> Html Msg
headerDiv context maybeInbound elementId coto =
    div
        [ class "coto-header" ]
        [ App.Views.Reorder.maybeReorderTools context maybeInbound elementId
            |> Maybe.withDefault
                (context.session
                    |> Maybe.map
                        (\session ->
                            App.Views.CotoToolbar.view
                                context
                                session
                                maybeInbound
                                elementId
                                coto
                        )
                    |> Maybe.withDefault
                        Utils.HtmlUtil.none
                )
        , coto.postedIn
            |> Maybe.map
                (\postedIn ->
                    if App.Submodels.Context.orignatedHere coto context then
                        Utils.HtmlUtil.none

                    else
                        a
                            [ class "posted-in"
                            , href ("/cotonomas/" ++ postedIn.key)
                            , onLinkButtonClick (App.Messages.CotonomaClick postedIn.key)
                            ]
                            [ text postedIn.name ]
                )
            |> Maybe.withDefault Utils.HtmlUtil.none
        , if App.Types.Graph.pinned coto.id context.graph then
            faIcon "thumb-tack" (Just "coto-status pinned")

          else if App.Types.Graph.reachableFromPins coto.id context.graph then
            faIcon "sitemap" (Just "coto-status in-pinned-graph")

          else
            Utils.HtmlUtil.none
        ]



--
-- Parents
--


parentsDiv : Graph -> Maybe CotoId -> CotoId -> Html Msg
parentsDiv graph exclude childId =
    let
        parents =
            App.Types.Graph.getParents childId graph
                |> List.filter (\parent -> Just parent.id /= exclude)
    in
    if List.isEmpty parents then
        Utils.HtmlUtil.none

    else
        div [ class "parents" ]
            (List.map
                (\parent ->
                    div
                        [ class "parent"
                        , onClick (App.Messages.OpenTraversal parent.id)
                        ]
                        [ text (abbreviate parent) ]
                )
                parents
            )



--
-- Sub cotos
--


openTraversalButtonDiv : Graph -> Bool -> CotoId -> Html Msg
openTraversalButtonDiv graph isCotonoma cotoId =
    if isCotonoma || App.Types.Graph.hasChildren cotoId graph then
        div [ class "sub-cotos-button" ] [ openTraversalButton cotoId ]

    else
        Utils.HtmlUtil.none


openTraversalButton : CotoId -> Html Msg
openTraversalButton cotoId =
    a
        [ class "tool-button open-traversal"
        , title "Open sub cotos"
        , onLinkButtonClick (App.Messages.OpenTraversal cotoId)
        ]
        [ materialIcon "view_headline" Nothing ]


subCotosDiv : Context a -> ElementId -> Coto -> Html Msg
subCotosDiv context parentElementId coto =
    let
        maybeConnections =
            Dict.get coto.id context.graph.connections
    in
    div []
        [ if isJust maybeConnections || isJust coto.asCotonoma then
            div [ class "main-sub-border" ] []

          else
            Utils.HtmlUtil.none
        , loadSubgraphButton context coto
        , if App.Submodels.Context.hasSubCotosInReordering parentElementId context then
            App.Views.Reorder.closeButtonDiv context

          else
            Utils.HtmlUtil.none
        , maybeConnections
            |> Maybe.map (connectionsDiv context parentElementId coto)
            |> Maybe.withDefault Utils.HtmlUtil.none
        ]


loadSubgraphButton : Context context -> Coto -> Html Msg
loadSubgraphButton context coto =
    coto.asCotonoma
        |> Maybe.map
            (\cotonoma ->
                if App.Types.Graph.hasSubgraphLoaded cotonoma.key context.graph then
                    Utils.HtmlUtil.none

                else
                    div [ class "load-subgraph" ]
                        [ if App.Types.Graph.hasSubgraphLoading cotonoma.key context.graph then
                            Utils.HtmlUtil.loadingHorizontalImg

                          else
                            a
                                [ class "tool-button"
                                , title "Load sub cotos"
                                , onLinkButtonClick (App.Messages.LoadSubgraph cotonoma.key)
                                ]
                                [ materialIcon "more_horiz" Nothing ]
                        ]
            )
        |> Maybe.withDefault Utils.HtmlUtil.none


connectionsDiv : Context context -> ElementId -> Coto -> List Connection -> Html Msg
connectionsDiv context parentElementId parentCoto connections =
    connections
        |> List.reverse
        |> List.indexedMap
            (\index connection ->
                context.graph.cotos
                    |> Dict.get connection.end
                    |> Maybe.map
                        (\coto ->
                            ( App.Types.Connection.makeUniqueKey connection
                            , div
                                [ class "outbound-conn" ]
                                [ subCotoDiv
                                    context
                                    parentElementId
                                    (InboundConnection
                                        (Just parentCoto)
                                        (Just parentElementId)
                                        connection
                                        (List.length connections)
                                        index
                                        (App.Submodels.Context.hasSubCotosInReordering
                                            parentElementId
                                            context
                                        )
                                    )
                                    coto
                                ]
                            )
                        )
                    |> Maybe.withDefault
                        ( App.Types.Connection.makeUniqueKey connection
                        , Utils.HtmlUtil.none
                        )
            )
        |> Html.Keyed.node "div" [ class "sub-cotos" ]


subCotoDiv : Context a -> ElementId -> InboundConnection -> Coto -> Html Msg
subCotoDiv context parentElementId inbound coto =
    let
        elementId =
            parentElementId ++ "-" ++ coto.id

        maybeParentId =
            inbound.parent |> Maybe.map (\parent -> parent.id)
    in
    div
        [ cotoClassList context elementId (Just coto.id) []
        , onClickWithoutPropagation (App.Messages.CotoClick elementId coto.id)
        , onMouseEnter (App.Messages.CotoMouseEnter elementId coto.id)
        , onMouseLeave (App.Messages.CotoMouseLeave elementId coto.id)
        ]
        [ div
            [ class "coto-inner" ]
            [ linkingPhraseDiv context inbound coto
            , headerDiv context (Just inbound) elementId coto
            , parentsDiv context.graph maybeParentId coto.id
            , div [ class "sub-coto-body" ]
                [ bodyDivByCoto context (Just inbound) elementId coto
                , openTraversalButtonDiv context.graph (isJust coto.asCotonoma) coto.id
                ]
            ]
        ]


linkingPhraseDiv : Context context -> InboundConnection -> Coto -> Html Msg
linkingPhraseDiv context inbound coto =
    let
        canUpdate =
            Maybe.map2
                (\session parent ->
                    App.Types.Connection.canUpdate
                        session
                        parent
                        inbound.connection
                )
                context.session
                inbound.parent
                |> Maybe.withDefault False
    in
    Maybe.map2
        (\parent linkingPhrase ->
            div [ class "linking-phrase" ]
                [ if canUpdate then
                    a
                        [ class "linking-phrase tool-button"
                        , onLinkButtonClick
                            (App.Messages.OpenConnectionModal
                                inbound.connection
                                parent
                                coto
                            )
                        ]
                        [ text linkingPhrase ]

                  else
                    span
                        [ class "linking-phrase" ]
                        [ text linkingPhrase ]
                ]
        )
        inbound.parent
        inbound.connection.linkingPhrase
        |> Maybe.withDefault Utils.HtmlUtil.none



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
                    String.left maxLength text
                        ++ (if String.length text > maxLength then
                                "..."

                            else
                                ""
                           )
               )
        )
        summary


isCotonomaAccessible : Context a -> Maybe Amishi -> Cotonoma -> Bool
isCotonomaAccessible context maybeOwner cotonoma =
    if cotonoma.shared then
        True

    else
        Maybe.map2
            (\session owner -> session.amishi.id == owner.id)
            context.session
            maybeOwner
            |> Maybe.withDefault False



{-
   cotonomaLink, cotonomaLabel:
   The owner should be passed separately because cotonoma.owner possibly isn't populated.
-}


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
