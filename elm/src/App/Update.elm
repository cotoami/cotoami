module App.Update exposing (..)

import Set
import Task
import Process
import Time
import Maybe exposing (andThen, withDefault)
import Json.Decode as Decode
import Http exposing (Error(..))
import Util.Keys exposing (enter, escape)
import Navigation
import Util.StringUtil exposing (isNotBlank)
import App.ActiveViewOnMobile exposing (ActiveViewOnMobile(..))
import App.Types.Context exposing (..)
import App.Types.Amishi exposing (Presences, applyPresenceDiff)
import App.Types.Coto exposing (Coto, ElementId, CotoId, CotonomaKey)
import App.Types.Post exposing (Post, toCoto, isPostedInCoto, isSelfOrPostedIn)
import App.Types.Graph exposing (..)
import App.Types.Post exposing (Post, defaultPost)
import App.Types.Timeline
    exposing
        ( setEditingNew
        , updatePost
        , setLoading
        , postContent
        , setCotoSaved
        , setBeingDeleted
        , deletePendingPost
        )
import App.Types.Traversal exposing (closeTraversal, defaultTraversals, updateTraversal, doTraverse)
import App.Model exposing (..)
import App.Messages exposing (..)
import App.Confirmation exposing (Confirmation)
import App.Route exposing (parseLocation, Route(..))
import App.Server.Session exposing (decodeSessionNotFoundBodyString)
import App.Server.Cotonoma exposing (fetchCotonomas, fetchSubCotonomas, pinOrUnpinCotonoma)
import App.Server.Post exposing (fetchPosts, fetchCotonomaPosts, decodePost, postCotonoma)
import App.Server.Coto exposing (deleteCoto)
import App.Server.Graph exposing (fetchGraph, fetchSubgraphIfCotonoma)
import App.Commands exposing (sendMsg)
import App.Channels exposing (Payload, decodePayload, decodePresenceState, decodePresenceDiff)
import App.Modals.SigninModal exposing (setSignupEnabled)
import App.Modals.InviteModal
import App.Modals.CotoModal
import App.Modals.CotonomaModal
import App.Modals.ImportModal


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            model ! []

        KeyDown keyCode ->
            { model
                | context = App.Types.Context.keyDown keyCode model.context
            }
                |> (\model ->
                        if keyCode == escape.keyCode then
                            closeModal model
                        else
                            model
                   )
                |> \model -> model ! []

        KeyUp keyCode ->
            { model
                | context = App.Types.Context.keyUp keyCode model.context
            }
                ! []

        OnLocationChange location ->
            parseLocation location
                |> (\route -> ( route, { model | route = route } ))
                |> \( route, model ) ->
                    case route of
                        HomeRoute ->
                            loadHome model

                        CotonomaRoute key ->
                            loadCotonoma key model

                        NotFoundRoute ->
                            ( model, Cmd.none )

        NavigationToggle ->
            { model
                | navigationToggled = True
                , navigationOpen = (not model.navigationOpen)
            }
                ! []

        SwitchViewOnMobile view ->
            { model
                | activeViewOnMobile = view
            }
                ! []

        HomeClick ->
            changeLocationToHome model

        CotonomaPresenceState payload ->
            { model | presences = decodePresenceState payload } ! []

        CotonomaPresenceDiff payload ->
            decodePresenceDiff payload
                |> (\diff -> applyPresenceDiff diff model.presences)
                |> \presences -> { model | presences = presences } ! []

        --
        -- Fetched
        --
        SessionFetched (Ok session) ->
            { model | context = setSession session model.context }
                |> (\model ->
                        case model.route of
                            CotonomaRoute key ->
                                loadCotonoma key model

                            _ ->
                                loadHome model
                   )

        SessionFetched (Err error) ->
            case error of
                BadStatus response ->
                    if response.status.code == 404 then
                        decodeSessionNotFoundBodyString response.body
                            |> (\body -> setSignupEnabled body.signupEnabled model.signinModal)
                            |> (\signinModal -> { model | signinModal = signinModal })
                            |> openModal App.Model.SigninModal
                            |> \model -> model ! []
                    else
                        model ! []

                _ ->
                    model ! []

        CotonomasFetched (Ok ( pinned, recent )) ->
            { model
                | pinnedCotonomas = pinned
                , recentCotonomas = recent
                , cotonomasLoading = False
            }
                ! []

        CotonomasFetched (Err _) ->
            { model | cotonomasLoading = False } ! []

        SubCotonomasFetched (Ok cotonomas) ->
            { model | subCotonomas = cotonomas } ! []

        SubCotonomasFetched (Err _) ->
            model ! []

        CotonomaFetched (Ok ( cotonoma, posts )) ->
            { model
                | context = setCotonoma (Just cotonoma) model.context
                , navigationOpen = False
                , timeline = App.Types.Timeline.setPosts posts model.timeline
            }
                ! [ App.Commands.scrollTimelineToBottom NoOp
                  , fetchSubCotonomas (Just cotonoma)
                  ]

        CotonomaFetched (Err _) ->
            model ! []

        CotonomaStatsFetched (Ok stats) ->
            model.cotoModal
                |> Maybe.map (\cotoModal -> { cotoModal | cotonomaStats = Just stats })
                |> Maybe.map (\cotoModal -> { model | cotoModal = Just cotoModal })
                |> Maybe.withDefault model
                |> (\model -> ( model, Cmd.none ))

        CotonomaStatsFetched (Err _) ->
            model ! []

        GraphFetched (Ok graph) ->
            { model | graph = graph } ! []

        GraphFetched (Err _) ->
            model ! []

        SubgraphFetched (Ok subgraph) ->
            { model | graph = mergeSubgraph subgraph model.graph } ! []

        SubgraphFetched (Err _) ->
            model ! []

        --
        -- Modal
        --
        CloseModal ->
            ( closeModal model, Cmd.none )

        Confirm ->
            ( closeModal model, sendMsg model.confirmation.msgOnConfirm )

        OpenSigninModal ->
            { model | signinModal = App.Modals.SigninModal.defaultModel }
                |> \model -> openModal App.Model.SigninModal model ! []

        OpenInviteModal ->
            { model | inviteModal = App.Modals.InviteModal.defaultModel }
                |> \model -> openModal App.Model.InviteModal model ! []

        OpenProfileModal ->
            openModal App.Model.ProfileModal model ! []

        OpenCotoModal coto ->
            openCoto coto model

        OpenCotonomaModal ->
            { model | cotonomaModal = App.Modals.CotonomaModal.defaultModel }
                |> \model -> openModal App.Model.CotonomaModal model ! []

        OpenImportModal ->
            { model | importModal = App.Modals.ImportModal.defaultModel }
                |> \model -> openModal App.Model.ImportModal model ! []

        --
        -- Coto
        --
        CotoClick elementId cotoId ->
            clickCoto elementId cotoId model ! []

        CotoMouseEnter elementId cotoId ->
            { model
                | context =
                    model.context
                        |> setElementFocus (Just elementId)
                        |> setCotoFocus (Just cotoId)
            }
                ! []

        CotoMouseLeave elementId cotoId ->
            { model
                | context =
                    model.context
                        |> setElementFocus Nothing
                        |> setCotoFocus Nothing
            }
                ! []

        SelectCoto cotoId ->
            ( { model
                | context = updateSelection cotoId model.context
              }
                |> closeSelectionColumnIfEmpty
            , Cmd.none
            )

        OpenTraversal cotoId ->
            model
                |> openTraversal cotoId
                |> \model ->
                    ( model
                    , Cmd.batch
                        [ App.Commands.scrollMainContentToRight NoOp
                        , fetchSubgraphIfCotonoma model.graph cotoId
                        ]
                    )

        CotonomaClick key ->
            changeLocationToCotonoma key model

        ToggleCotoContent elementId ->
            ( { model | context = toggleContent elementId model.context }
            , Cmd.none
            )

        ConfirmDeleteCoto ->
            ( confirm
                (Confirmation
                    "Are you sure you want to delete this coto?"
                    (model.cotoModal
                        |> Maybe.map (\cotoModal -> RequestDeleteCoto cotoModal.coto)
                        |> Maybe.withDefault App.Messages.NoOp
                    )
                )
                model
            , Cmd.none
            )

        RequestDeleteCoto coto ->
            ({ model | timeline = setBeingDeleted coto model.timeline }
                |> clearModals
            )
                ! [ deleteCoto coto.id
                  , Process.sleep (1 * Time.second)
                        |> Task.andThen (\_ -> Task.succeed ())
                        |> Task.perform (\_ -> DeleteCoto coto)
                  ]

        DeleteCoto coto ->
            { model
                | timeline = App.Types.Timeline.deleteCoto coto model.timeline
                , graph = removeCoto coto.id model.graph |> \( graph, _ ) -> graph
                , traversals = closeTraversal coto.id model.traversals
                , context = deleteSelection coto.id model.context
            }
                ! (if coto.asCotonoma then
                    [ fetchCotonomas
                    , fetchSubCotonomas model.context.cotonoma
                    ]
                   else
                    []
                  )

        CotoDeleted _ ->
            model ! []

        ContentUpdated (Ok coto) ->
            (model.cotoModal
                |> Maybe.map (App.Modals.CotoModal.setContentUpdated coto)
                |> (\maybeCotoModal -> { model | cotoModal = maybeCotoModal })
                |> updateCotoContent coto
                |> updateRecentCotonomasByCoto coto
            )
                ! if coto.asCotonoma then
                    [ fetchCotonomas
                    , fetchSubCotonomas model.context.cotonoma
                    ]
                  else
                    []

        ContentUpdated (Err error) ->
            model.cotoModal
                |> Maybe.map (App.Modals.CotoModal.setContentUpdateError error)
                |> (\maybeCotoModal -> { model | cotoModal = maybeCotoModal })
                |> \model -> model ! []

        Cotonomatized (Ok coto) ->
            ( model.cotoModal
                |> Maybe.map (App.Modals.CotoModal.setCotonomatized coto)
                |> (\maybeCotoModal -> { model | cotoModal = maybeCotoModal })
                |> App.Model.cotonomatize coto.id coto.cotonomaKey
            , Cmd.batch
                [ fetchCotonomas
                , fetchSubCotonomas model.context.cotonoma
                ]
            )

        Cotonomatized (Err error) ->
            model.cotoModal
                |> Maybe.map (App.Modals.CotoModal.setContentUpdateError error)
                |> (\maybeCotoModal -> { model | cotoModal = maybeCotoModal })
                |> \model -> model ! []

        PinCoto cotoId ->
            (Maybe.map2
                (\session coto ->
                    { model | graph = pinCoto session coto model.graph }
                        ! [ App.Server.Graph.pinCotos
                                (Maybe.map (\cotonoma -> cotonoma.key) model.context.cotonoma)
                                [ cotoId ]
                          , App.Commands.scrollPinnedCotosToBottom NoOp
                          ]
                )
                model.context.session
                (App.Model.getCoto cotoId model)
            )
                |> withDefault (model ! [])

        CotoPinned (Ok _) ->
            model ! []

        CotoPinned (Err _) ->
            model ! []

        ConfirmUnpinCoto cotoId ->
            ( confirm
                (Confirmation
                    "Are you sure you want to unpin this coto?"
                    (UnpinCoto cotoId)
                )
                model
            , Cmd.none
            )

        UnpinCoto cotoId ->
            { model | graph = model.graph |> unpinCoto cotoId }
                ! [ App.Server.Graph.unpinCoto
                        (Maybe.map (\cotonoma -> cotonoma.key) model.context.cotonoma)
                        cotoId
                  ]

        CotoUnpinned (Ok _) ->
            model ! []

        CotoUnpinned (Err _) ->
            model ! []

        ConfirmConnect cotoId direction ->
            { model
                | connectingSubject =
                    App.Model.getCoto cotoId model
                        |> Maybe.map App.Model.Coto
                , connectingDirection = direction
            }
                |> \model -> openModal App.Model.ConnectModal model ! []

        ReverseDirection ->
            { model
                | connectingDirection =
                    case model.connectingDirection of
                        Outbound ->
                            Inbound

                        Inbound ->
                            Outbound
            }
                ! []

        Connect subject objects direction ->
            App.Model.connect direction objects subject model
                ! [ App.Server.Graph.connect
                        (Maybe.map (\cotonoma -> cotonoma.key) model.context.cotonoma)
                        direction
                        (List.map (\coto -> coto.id) objects)
                        subject.id
                  ]

        Connected (Ok _) ->
            model ! []

        Connected (Err _) ->
            model ! []

        ConfirmDeleteConnection conn ->
            ( confirm
                (Confirmation
                    "Are you sure you want to delete this connection?"
                    (DeleteConnection conn)
                )
                model
            , Cmd.none
            )

        DeleteConnection ( startId, endId ) ->
            { model
                | graph = disconnect ( startId, endId ) model.graph
            }
                ! [ App.Server.Graph.disconnect
                        (Maybe.map (\cotonoma -> cotonoma.key) model.context.cotonoma)
                        startId
                        endId
                  ]

        ConnectionDeleted (Ok _) ->
            model ! []

        ConnectionDeleted (Err _) ->
            model ! []

        --
        -- Cotonoma
        --
        PinOrUnpinCotonoma cotonomaKey pinOrUnpin ->
            model.cotoModal
                |> Maybe.map (\modal -> { modal | waitingToPinOrUnpinCotonoma = True })
                |> (\modal -> { model | cotoModal = modal })
                |> (\model -> model ! [ pinOrUnpinCotonoma pinOrUnpin cotonomaKey ])

        CotonomaPinnedOrUnpinned (Ok _) ->
            ({ model | cotonomasLoading = True } |> closeModal)
                ! [ fetchCotonomas ]

        CotonomaPinnedOrUnpinned (Err _) ->
            model ! []

        --
        -- Timeline
        --
        PostsFetched (Ok posts) ->
            { model
                | context = setCotonoma Nothing model.context
                , timeline = App.Types.Timeline.setPosts posts model.timeline
            }
                ! [ App.Commands.scrollTimelineToBottom NoOp ]

        PostsFetched (Err _) ->
            model ! []

        ImageLoaded ->
            model ! [ App.Commands.scrollTimelineToBottom NoOp ]

        EditorFocus ->
            { model | timeline = setEditingNew True model.timeline } ! []

        EditorBlur ->
            { model | timeline = setEditingNew False model.timeline } ! []

        EditorInput content ->
            { model | timeline = model.timeline |> \t -> { t | newContent = content } } ! []

        EditorKeyDown keyCode ->
            if
                (keyCode == enter.keyCode)
                    && not (Set.isEmpty model.context.modifierKeys)
                    && isNotBlank model.timeline.newContent
            then
                if isCtrlDown model.context then
                    post Nothing model
                else if isAltDown model.context && anySelection model.context then
                    confirmPostAndConnect model ! []
                else
                    model ! []
            else
                model ! []

        Post ->
            post Nothing model

        Posted postId (Ok response) ->
            ( { model | timeline = setCotoSaved postId response model.timeline }
                |> updateRecentCotonomasByCoto response
            , Cmd.none
            )

        Posted postId (Err _) ->
            model ! []

        ConfirmPostAndConnect ->
            confirmPostAndConnect model ! []

        PostAndConnect ->
            post (Just model.connectingDirection) model

        PostedAndConnect postId (Ok response) ->
            { model | timeline = setCotoSaved postId response model.timeline }
                |> (\model ->
                        response.cotoId
                            |> andThen (\cotoId -> App.Model.getCoto cotoId model)
                            |> Maybe.map
                                (\subject ->
                                    let
                                        direction =
                                            model.connectingDirection

                                        objects =
                                            getSelectedCotos model

                                        maybeCotonomaKey =
                                            Maybe.map (\cotonoma -> cotonoma.key) model.context.cotonoma
                                    in
                                        ( App.Model.connect direction objects subject model
                                        , App.Server.Graph.connect
                                            maybeCotonomaKey
                                            direction
                                            (List.map (\coto -> coto.id) objects)
                                            subject.id
                                        )
                                )
                            |> withDefault (model ! [])
                   )

        PostedAndConnect postId (Err _) ->
            model ! []

        PostCotonoma ->
            let
                ( timeline, _ ) =
                    postContent model.context True model.cotonomaModal.name model.timeline

                cotonomaModal =
                    model.cotonomaModal
                        |> \modal -> { modal | requestProcessing = True }
            in
                { model
                    | timeline = timeline
                    , cotonomaModal = cotonomaModal
                }
                    ! [ App.Commands.scrollTimelineToBottom NoOp
                      , postCotonoma
                            model.context.clientId
                            model.context.cotonoma
                            timeline.postIdCounter
                            model.cotonomaModal.name
                      ]

        CotonomaPosted postId (Ok response) ->
            ({ model
                | cotonomasLoading = True
                , timeline = setCotoSaved postId response model.timeline
             }
                |> closeModal
            )
                ! [ fetchCotonomas
                  , fetchSubCotonomas model.context.cotonoma
                  ]

        CotonomaPosted postId (Err error) ->
            App.Modals.CotonomaModal.updateRequestStatus error model.cotonomaModal
                |> (\( modal, postId ) ->
                        ( { model
                            | cotonomaModal = modal
                            , timeline = deletePendingPost postId model.timeline
                          }
                        , Cmd.none
                        )
                   )

        OpenPost post ->
            case toCoto post of
                Nothing ->
                    model ! []

                Just coto ->
                    openCoto coto model

        PostPushed payload ->
            case Decode.decodeValue (decodePayload "post" decodePost) payload of
                Ok decodedPayload ->
                    handlePushedPost model.context.clientId decodedPayload model

                Err err ->
                    model ! []

        CotonomaPushed post ->
            model
                ! [ fetchCotonomas
                  , fetchSubCotonomas model.context.cotonoma
                  ]

        --
        -- Traversals
        --
        TraverseClick traverse ->
            { model
                | traversals = updateTraversal (doTraverse traverse) model.traversals
            }
                ! []

        CloseTraversal cotoId ->
            { model
                | traversals = closeTraversal cotoId model.traversals
            }
                ! []

        SwitchTraversal pageIndex ->
            { model
                | traversals = model.traversals |> \t -> { t | activeIndexOnMobile = pageIndex }
            }
                ! []

        --
        -- CotoSelection
        --
        DeselectingCoto cotoId ->
            { model | context = setBeingDeselected cotoId model.context }
                ! [ Process.sleep (1 * Time.second)
                        |> Task.andThen (\_ -> Task.succeed ())
                        |> Task.perform (\_ -> DeselectCoto)
                  ]

        DeselectCoto ->
            ( { model | context = finishBeingDeselected model.context }
                |> closeSelectionColumnIfEmpty
            , Cmd.none
            )

        ClearSelection ->
            { model
                | context = clearSelection model.context
                , connectingSubject = Nothing
                , cotoSelectionColumnOpen = False
                , activeViewOnMobile =
                    case model.activeViewOnMobile of
                        SelectionView ->
                            TimelineView

                        anotherView ->
                            anotherView
            }
                ! []

        CotoSelectionColumnToggle ->
            { model
                | cotoSelectionColumnOpen = (not model.cotoSelectionColumnOpen)
            }
                ! []

        --
        -- Sub components
        --
        SigninModalMsg subMsg ->
            App.Modals.SigninModal.update subMsg model.signinModal
                |> \( signinModal, subCmd ) ->
                    { model | signinModal = signinModal } ! [ Cmd.map SigninModalMsg subCmd ]

        InviteModalMsg subMsg ->
            App.Modals.InviteModal.update subMsg model.inviteModal
                |> \( inviteModal, subCmd ) ->
                    { model | inviteModal = inviteModal } ! [ Cmd.map InviteModalMsg subCmd ]

        CotonomaModalMsg subMsg ->
            model.context.session
                |> Maybe.map
                    (\session ->
                        App.Modals.CotonomaModal.update
                            subMsg
                            session
                            model.context
                            model.cotonomaModal
                    )
                |> Maybe.map
                    (\( cotonomaModal, subCmd ) ->
                        { model | cotonomaModal = cotonomaModal }
                            ! [ Cmd.map CotonomaModalMsg subCmd ]
                    )
                |> withDefault (model ! [])

        CotoModalMsg subMsg ->
            model.cotoModal
                |> Maybe.map (App.Modals.CotoModal.update subMsg)
                |> Maybe.map
                    (\( cotoModal, maybeConfirmation, cmd ) ->
                        { model | cotoModal = Just cotoModal }
                            |> maybeConfirm maybeConfirmation
                            |> (\model -> ( model, cmd ))
                    )
                |> withDefault (model ! [])

        ImportModalMsg subMsg ->
            App.Modals.ImportModal.update subMsg model.importModal
                |> \( importModal, subCmd ) ->
                    { model | importModal = importModal } ! [ Cmd.map ImportModalMsg subCmd ]


changeLocationToHome : Model -> ( Model, Cmd Msg )
changeLocationToHome model =
    ( model, Navigation.newUrl "/" )


loadHome : Model -> ( Model, Cmd Msg )
loadHome model =
    { model
        | context =
            model.context
                |> setCotonomaLoading
                |> clearSelection
        , cotonomasLoading = True
        , subCotonomas = []
        , timeline = setLoading model.timeline
        , connectingSubject = Nothing
        , graph = defaultGraph
        , traversals = defaultTraversals
        , activeViewOnMobile = TimelineView
    }
        ! [ fetchPosts
          , fetchCotonomas
          , fetchGraph Nothing
          ]


changeLocationToCotonoma : CotonomaKey -> Model -> ( Model, Cmd Msg )
changeLocationToCotonoma key model =
    ( model, Navigation.newUrl ("/cotonomas/" ++ key) )


loadCotonoma : CotonomaKey -> Model -> ( Model, Cmd Msg )
loadCotonoma key model =
    { model
        | context =
            model.context
                |> setCotonomaLoading
                |> clearSelection
        , cotonomasLoading = True
        , timeline = setLoading model.timeline
        , connectingSubject = Nothing
        , graph = defaultGraph
        , traversals = defaultTraversals
        , activeViewOnMobile = TimelineView
        , navigationOpen = False
    }
        ! [ fetchCotonomas
          , fetchCotonomaPosts key
          , fetchGraph (Just key)
          ]


handlePushedPost : String -> Payload Post -> Model -> ( Model, Cmd Msg )
handlePushedPost clientId payload model =
    if payload.clientId /= clientId then
        (model.timeline
            |> (\timeline -> ( timeline, payload.body :: timeline.posts ))
            |> (\( timeline, posts ) -> { timeline | posts = posts })
            |> (\timeline -> { model | timeline = timeline })
        )
            ! if payload.body.asCotonoma then
                [ App.Commands.scrollTimelineToBottom NoOp
                , sendMsg (CotonomaPushed payload.body)
                ]
              else
                [ App.Commands.scrollTimelineToBottom NoOp ]
    else
        model ! []


post : Maybe Direction -> Model -> ( Model, Cmd Msg )
post maybeDirection model =
    let
        clientId =
            model.context.clientId

        cotonoma =
            model.context.cotonoma

        newContent =
            model.timeline.newContent

        ( timeline, newPost ) =
            postContent model.context False newContent model.timeline

        postMsg =
            case maybeDirection of
                Nothing ->
                    Posted timeline.postIdCounter

                Just _ ->
                    PostedAndConnect timeline.postIdCounter
    in
        { model
            | timeline = timeline
            , connectingDirection =
                Maybe.withDefault Outbound maybeDirection
        }
            ! [ App.Commands.scrollTimelineToBottom NoOp
              , App.Server.Post.post clientId cotonoma postMsg newPost
              ]


openCoto : Coto -> Model -> ( Model, Cmd Msg )
openCoto coto model =
    ( App.Model.openCoto coto model
    , coto.cotonomaKey
        |> Maybe.map (\key -> App.Server.Cotonoma.fetchStats key)
        |> Maybe.withDefault Cmd.none
    )
