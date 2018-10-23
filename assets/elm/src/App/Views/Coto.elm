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
import App.Types.Connection exposing (Direction(..), Connection, InboundConnection, Reordering(..))
import App.Types.Graph exposing (Graph)
import App.Submodels.Context exposing (Context)
import App.Messages exposing (..)
import App.Views.CotoToolbar
import App.Views.Reorder


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


bodyDiv : Context a -> Maybe InboundConnection -> ElementId -> Markdown -> BodyModel r -> Html Msg
bodyDiv context maybeInbound elementId markdown model =
    div [ class "coto-body" ]
        [ model.asCotonoma
            |> Maybe.map (cotonomaLink context CotonomaClick model.amishi)
            |> Maybe.withDefault
                (if App.Types.Connection.inReordering maybeInbound then
                    div [ class "content-in-reorder" ]
                        [ text (abbreviate model) ]
                 else
                    contentDiv context elementId markdown model
                )
        ]


bodyDivByCoto : Context a -> Maybe InboundConnection -> ElementId -> Coto -> Html Msg
bodyDivByCoto context maybeInbound elementId coto =
    bodyDiv context maybeInbound elementId App.Markdown.markdown coto


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



--
-- Header
--


headerDiv : Context a -> Graph -> Maybe InboundConnection -> ElementId -> Coto -> Html Msg
headerDiv context graph maybeInbound elementId coto =
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
                                graph
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
    graph.connections
        |> Dict.get coto.id
        |> Maybe.map
            (\connections ->
                div []
                    [ div [ class "main-sub-border" ] []
                    , if App.Submodels.Context.reorderingSubCotos context parentElementId then
                        App.Views.Reorder.closeButtonDiv context
                      else
                        Utils.HtmlUtil.none
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
                                        (Just parentElementId)
                                        connection
                                        (List.length connections)
                                        index
                                        (App.Submodels.Context.reorderingSubCotos
                                            context
                                            parentElementId
                                        )
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
                    [ bodyDivByCoto context (Just inbound) elementId coto
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
