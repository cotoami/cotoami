module App.Modals.RepostModal exposing
    ( Model
    , defaultModel
    , initModel
    , update
    , view
    )

import App.I18n.Keys as I18nKeys
import App.Messages as AppMsg
import App.Modals.RepostModalMsg as ModalMsg exposing (Msg(..))
import App.Server.Cotonoma
import App.Server.Post
import App.Submodels.Context exposing (Context)
import App.Submodels.LocalCotos exposing (LocalCotos)
import App.Types.Coto exposing (Coto, Cotonoma)
import App.Types.Session exposing (Session)
import App.Views.Coto
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import Html.Keyed
import Utils.HtmlUtil exposing (materialIcon)
import Utils.Modal
import Utils.StringUtil
import Utils.UpdateUtil exposing (..)


type alias Model =
    { coto : Coto
    , cotonomaKeyOrName : String
    , inputCounter : Int
    , lastFetchRequestId : Int
    , cotonoma : Maybe Cotonoma
    , requestProcessing : Bool
    }


defaultModel : Model
defaultModel =
    { coto = App.Types.Coto.defaultCoto
    , cotonomaKeyOrName = ""
    , inputCounter = 0
    , lastFetchRequestId = 0
    , cotonoma = Nothing
    , requestProcessing = False
    }


initModel : Coto -> Model
initModel coto =
    { defaultModel | coto = coto }


getCotonomaName : Model -> String
getCotonomaName model =
    model.cotonoma
        |> Maybe.map .name
        |> Maybe.withDefault (String.trim model.cotonomaKeyOrName)


clearInput : Model -> Model
clearInput model =
    { model
        | cotonomaKeyOrName = ""
        , inputCounter = model.inputCounter + 1
    }


isRepostable : Context context -> Model -> Bool
isRepostable context model =
    let
        cotonomaName =
            getCotonomaName model

        alreadyPostedIn =
            model.coto.postedIn
                |> Maybe.map (\postedIn -> postedIn :: model.coto.repostedIn)
                |> Maybe.withDefault model.coto.repostedIn

        alreadyPostedInIds =
            List.map .id alreadyPostedIn

        alreadyPostedInNames =
            List.map .name alreadyPostedIn
    in
    if Utils.StringUtil.isBlank cotonomaName then
        False

    else
        model.cotonoma
            |> Maybe.map (\cotonoma -> not (List.member cotonoma.id alreadyPostedInIds))
            |> Maybe.withDefault (not (List.member cotonomaName alreadyPostedInNames))


view : Context context -> Session -> Model -> Html AppMsg.Msg
view context session model =
    model
        |> modalConfig context session
        |> Utils.Modal.view "repost-modal"


modalConfig : Context context -> Session -> Model -> Utils.Modal.Config AppMsg.Msg
modalConfig context session model =
    { closeMessage = AppMsg.CloseModal
    , title = text (context.i18nText I18nKeys.RepostModal_Title)
    , content =
        div []
            [ div [ class "target-coto" ]
                [ App.Views.Coto.simplifiedCotoDiv model.coto ]
            , div [ class "repost-form" ]
                [ div
                    [ classList
                        [ ( "cotonoma-key-or-name-input", True )
                        , ( "blank", Utils.StringUtil.isBlank model.cotonomaKeyOrName )
                        ]
                    ]
                    [ cotonomaInputStatusSpan model
                    , Html.Keyed.node
                        "div"
                        []
                        [ ( toString model.inputCounter
                          , input
                                [ type_ "text"
                                , class "cotonoma-key-or-name u-full-width"
                                , placeholder (context.i18nText I18nKeys.RepostModal_CotonomaKeyOrName)
                                , defaultValue model.cotonomaKeyOrName
                                , onInput (AppMsg.RepostModalMsg << CotonomaKeyOrNameInput)
                                , disabled model.requestProcessing
                                ]
                                []
                          )
                        ]
                    ]
                , div [ class "repost-button" ]
                    [ button
                        [ title (context.i18nText I18nKeys.Repost)
                        , onClick (AppMsg.RepostModalMsg Repost)
                        , disabled
                            (not (isRepostable context model)
                                || model.requestProcessing
                            )
                        ]
                        [ materialIcon "repeat" Nothing ]
                    ]
                ]
            , model.cotonoma
                |> Maybe.map
                    (\cotonoma ->
                        if String.trim model.cotonomaKeyOrName /= cotonoma.name then
                            div [ class "cotonoma-name-display" ]
                                [ div [ class "cotonoma-name" ] [ text cotonoma.name ] ]

                        else
                            Utils.HtmlUtil.none
                    )
                |> Maybe.withDefault Utils.HtmlUtil.none
            , if model.requestProcessing then
                div [ class "reposting" ] [ Utils.HtmlUtil.loadingHorizontalImg ]

              else
                Utils.HtmlUtil.none
            , div [ class "reposted-cotonomas" ]
                (List.map
                    (\cotonoma ->
                        div [ class "reposted-in" ]
                            [ div [ class "repost-icon" ] [ materialIcon "repeat" Nothing ]
                            , App.Views.Coto.simplifiedCotonomaDiv
                                cotonoma.owner
                                cotonoma
                            ]
                    )
                    model.coto.repostedIn
                )
            ]
    , buttons = []
    }


cotonomaInputStatusSpan : Model -> Html AppMsg.Msg
cotonomaInputStatusSpan model =
    span [ class "status" ]
        [ model.cotonoma
            |> Maybe.map cotonomaOwnerImg
            |> Maybe.withDefault (materialIcon "fiber_new" Nothing)
        ]


cotonomaOwnerImg : Cotonoma -> Html AppMsg.Msg
cotonomaOwnerImg cotonoma =
    cotonoma.owner
        |> Maybe.map (\owner -> img [ class "avatar", src owner.avatarUrl ] [])
        |> Maybe.withDefault Utils.HtmlUtil.none


type alias UpdateModel model =
    LocalCotos { model | repostModal : Model }


update : Context context -> ModalMsg.Msg -> UpdateModel model -> ( UpdateModel model, Cmd AppMsg.Msg )
update context msg ({ repostModal } as model) =
    case msg of
        CotonomaKeyOrNameInput keyOrName ->
            let
                requestId =
                    repostModal.lastFetchRequestId + 1

                modal =
                    { repostModal
                        | cotonomaKeyOrName = keyOrName
                        , lastFetchRequestId = requestId
                    }
            in
            { model | repostModal = modal }
                |> withCmdIf
                    (\_ -> Utils.StringUtil.isNotBlank keyOrName)
                    (\_ ->
                        App.Server.Cotonoma.fetchCotonomaByKeyOrName
                            (AppMsg.RepostModalMsg << CotonomaFetched requestId)
                            (String.trim keyOrName)
                    )

        Repost ->
            ( { model | repostModal = { repostModal | requestProcessing = True } }
            , repostModal.cotonoma
                |> Maybe.map
                    (\cotonoma ->
                        App.Server.Post.repostByCotonomaKey
                            context.clientId
                            (AppMsg.RepostModalMsg << Reposted)
                            cotonoma.key
                            repostModal.coto.id
                    )
                |> Maybe.withDefault
                    (App.Server.Post.repostByCotonomaName
                        context.clientId
                        (AppMsg.RepostModalMsg << Reposted)
                        (getCotonomaName repostModal)
                        repostModal.coto.id
                    )
            )

        Reposted (Ok post) ->
            let
                modal =
                    { repostModal
                        | coto = Maybe.withDefault repostModal.coto post.repost
                        , cotonoma = Nothing
                        , requestProcessing = False
                    }
                        |> clearInput

                model_ =
                    { model | repostModal = modal }
            in
            ( post.repost
                |> Maybe.map (\repost -> App.Submodels.LocalCotos.updateCoto repost model_)
                |> Maybe.withDefault model_
                |> App.Submodels.LocalCotos.addPostIfPostedHere post
            , App.Server.Cotonoma.refreshCotonomaList context
            )

        Reposted (Err error) ->
            model |> withoutCmd

        CotonomaFetched requestId (Ok cotonoma) ->
            if repostModal.lastFetchRequestId == requestId then
                { model | repostModal = { repostModal | cotonoma = Just cotonoma } }
                    |> withoutCmd

            else
                model |> withoutCmd

        CotonomaFetched requestId (Err _) ->
            if repostModal.lastFetchRequestId == requestId then
                { model | repostModal = { repostModal | cotonoma = Nothing } }
                    |> withoutCmd

            else
                model |> withoutCmd
