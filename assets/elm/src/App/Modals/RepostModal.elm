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
import App.Types.Coto exposing (Coto)
import App.Views.Coto
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import Utils.HtmlUtil exposing (materialIcon)
import Utils.Modal
import Utils.StringUtil
import Utils.UpdateUtil exposing (..)


type alias Model =
    { coto : Coto
    , cotonomaName : String
    , requestProcessing : Bool
    }


defaultModel : Model
defaultModel =
    { coto = App.Types.Coto.defaultCoto
    , cotonomaName = ""
    , requestProcessing = False
    }


initModel : Coto -> Model
initModel coto =
    { defaultModel | coto = coto }


validateCotonomaName : Context context -> Model -> Bool
validateCotonomaName context model =
    let
        existingNames =
            model.coto.repostedIn
                |> List.map (\cotonoma -> Just cotonoma.name)
                |> (::) (Maybe.map .name model.coto.postedIn)
                |> List.filterMap identity
    in
    Utils.StringUtil.isNotBlank model.cotonomaName
        && not (List.member model.cotonomaName existingNames)


view : Context context -> Model -> Html AppMsg.Msg
view context model =
    model
        |> modalConfig context
        |> Utils.Modal.view "repost-modal"


modalConfig : Context context -> Model -> Utils.Modal.Config AppMsg.Msg
modalConfig context model =
    { closeMessage = AppMsg.CloseModal
    , title = text (context.i18nText I18nKeys.RepostModal_Title)
    , content =
        div []
            [ div [ class "target-coto" ]
                [ App.Views.Coto.simplifiedCotoDiv model.coto ]
            , div [ class "repost-form" ]
                [ div [ class "cotonoma-name-input" ]
                    [ input
                        [ type_ "text"
                        , class "cotonoma-name u-full-width"
                        , placeholder (context.i18nText I18nKeys.RepostModal_CotonomaName)
                        , value model.cotonomaName
                        , onInput (AppMsg.RepostModalMsg << CotonomaNameInput)
                        ]
                        []
                    ]
                , div [ class "repost-button" ]
                    [ button
                        [ title (context.i18nText I18nKeys.Repost)
                        , onClick (AppMsg.RepostModalMsg Repost)
                        , disabled
                            (not (validateCotonomaName context model)
                                || model.requestProcessing
                            )
                        ]
                        [ materialIcon "repeat" Nothing ]
                    ]
                ]
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


type alias UpdateModel model =
    LocalCotos { model | repostModal : Model }


update : Context context -> ModalMsg.Msg -> UpdateModel model -> ( UpdateModel model, Cmd AppMsg.Msg )
update context msg ({ repostModal } as model) =
    case msg of
        CotonomaNameInput name ->
            { model | repostModal = { repostModal | cotonomaName = name } }
                |> withoutCmd

        Repost ->
            ( { model | repostModal = { repostModal | requestProcessing = True } }
            , App.Server.Post.repost context.clientId
                (AppMsg.RepostModalMsg << Reposted)
                repostModal.cotonomaName
                repostModal.coto.id
            )

        Reposted (Ok post) ->
            let
                modal =
                    { repostModal
                        | coto = Maybe.withDefault repostModal.coto post.repost
                        , cotonomaName = ""
                        , requestProcessing = False
                    }

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
