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
        , parentsDiv
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


headerDivWithDefaultConfig : Context -> Graph -> Maybe ( Coto, Connection ) -> ElementId -> Coto -> Html Msg
headerDivWithDefaultConfig context graph maybeInbound elementId coto =
    headerDiv context graph maybeInbound defaultActionConfig elementId coto


headerDiv : Context -> Graph -> Maybe ( Coto, Connection ) -> ActionConfig -> ElementId -> Coto -> Html Msg
headerDiv context graph maybeInbound config elementId coto =
    div
        [ class "coto-header" ]
        [ if App.Types.Context.inReorderMode elementId context then
            reorderToolButtonsSpan context elementId
          else
            toolButtonsSpan context graph maybeInbound config elementId coto
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


toolButtonsSpan :
    Context
    -> Graph
    -> Maybe ( Coto, Connection )
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
    , subCotoButtonsSpan context graph maybeInbound config elementId coto
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
    -> Maybe ( Coto, Connection )
    -> ActionConfig
    -> ElementId
    -> Coto
    -> Maybe (Html Msg)
subCotoButtonsSpan context graph maybeInbound config elementId coto =
    [ (Maybe.map3
        (\deleteConnection session ( parent, connection ) ->
            if isDisconnectable session parent connection coto then
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
        maybeInbound
      )
        |> Maybe.withDefault Nothing
    , (Maybe.map2
        (\toggleReorderMode session ->
            if isReorderble context session maybeInbound coto then
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


isReorderble : Context -> Session -> Maybe ( Coto, Connection ) -> Coto -> Bool
isReorderble context session maybeInbound child =
    if session.owner then
        True
    else
        maybeInbound
            |> Maybe.map
                (\( parent, _ ) ->
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


reorderToolButtonsSpan : Context -> ElementId -> Html Msg
reorderToolButtonsSpan context elementId =
    span [ class "reorder-tool-buttons" ]
        [ a
            [ class "tool-button move-to-top"
            , title "Move to the top"
            ]
            [ materialIcon "skip_previous" Nothing ]
        , a
            [ class "tool-button move-up"
            , title "Move up"
            ]
            [ materialIcon "play_arrow" Nothing ]
        , a
            [ class "tool-button move-down"
            , title "Move down"
            ]
            [ materialIcon "play_arrow" Nothing ]
        , a
            [ class "tool-button move-to-bottom"
            , title "Move to the bottom"
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
            div [] []
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


subCotosEllipsisDiv : Maybe CotoId -> Graph -> Html Msg
subCotosEllipsisDiv maybeCotoId graph =
    maybeCotoId
        |> Maybe.map
            (\cotoId ->
                if hasChildren cotoId graph then
                    div [ class "sub-cotos-button" ]
                        [ a
                            [ class "tool-button"
                            , onLinkButtonClick (OpenTraversal cotoId)
                            ]
                            [ materialIcon "more_horiz" Nothing ]
                        ]
                else
                    div [] []
            )
        |> Maybe.withDefault (div [] [])


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
subCotoDiv context graph parentElementId parentConnection coto =
    let
        elementId =
            parentElementId ++ "-" ++ coto.id

        ( parentCoto, connection ) =
            parentConnection
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
                    (Just parentConnection)
                    { defaultActionConfig
                        | toggleReorderMode = Just ToggleReorderMode
                    }
                    elementId
                    coto
                , parentsDiv graph (Just parentCoto.id) coto.id
                , bodyDivByCoto context elementId coto
                , subCotosEllipsisDiv (Just coto.id) graph
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
