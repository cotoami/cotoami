module App.Modals.InviteModal exposing (Model, defaultModel, update, view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import Http exposing (Error(..))
import Json.Decode as Decode
import Utils.StringUtil exposing (validateEmail)
import Utils.UpdateUtil exposing (withCmd, withoutCmd, addCmd)
import Utils.Modal as Modal
import App.I18n.Keys as I18nKeys
import App.Types.Amishi exposing (Amishi)
import App.Server.Amishi exposing (decodeAmishi)
import App.Messages as AppMsg exposing (Msg(CloseModal))
import App.Submodels.Context exposing (Context)
import App.Modals.InviteModalMsg as InviteModalMsg exposing (Msg(..))


type alias Model =
    { email : String
    , requestProcessing : Bool
    , requestStatus : RequestStatus
    }


type RequestStatus
    = None
    | Approved String
    | Conflict Amishi
    | Rejected


defaultModel : Model
defaultModel =
    { email = ""
    , requestProcessing = False
    , requestStatus = None
    }


update : InviteModalMsg.Msg -> Model -> ( Model, Cmd AppMsg.Msg )
update msg model =
    case msg of
        EmailInput content ->
            { model | email = content } |> withoutCmd

        SendInviteClick ->
            { model | requestProcessing = True }
                |> withCmd (\model -> sendInvite model.email)

        SendInviteDone (Ok _) ->
            { model
                | email = ""
                , requestProcessing = False
                , requestStatus = Approved model.email
            }
                |> withoutCmd

        SendInviteDone (Err error) ->
            (case error of
                BadStatus response ->
                    Just response.body

                _ ->
                    Nothing
            )
                |> Maybe.map (Decode.decodeString decodeAmishi)
                |> Maybe.andThen Result.toMaybe
                |> Maybe.map
                    (\invitee ->
                        { model
                            | requestProcessing = False
                            , requestStatus = Conflict invitee
                        }
                    )
                |> Maybe.withDefault
                    { model
                        | requestProcessing = False
                        , requestStatus = Rejected
                    }
                |> withoutCmd


sendInvite : String -> Cmd AppMsg.Msg
sendInvite email =
    Http.send
        (AppMsg.InviteModalMsg << SendInviteDone)
        (Http.get ("/api/invite/" ++ email) Decode.string)


view : Context context -> Model -> Html AppMsg.Msg
view context model =
    modalConfig context model
        |> Just
        |> Modal.view "invite-modal"


modalConfig : Context context -> Model -> Modal.Config AppMsg.Msg
modalConfig context model =
    case model.requestStatus of
        Approved acceptedEmail ->
            { closeMessage = CloseModal
            , title = text (context.i18nText I18nKeys.InviteModal_Title)
            , content =
                div []
                    [ p []
                        [ text (context.i18nText I18nKeys.InviteModal_SentMessage)
                        , span [ class "accepted-email" ] [ text acceptedEmail ]
                        ]
                    ]
            , buttons =
                [ button [ class "button", onClick CloseModal ] [ text "OK" ] ]
            }

        _ ->
            { closeMessage = CloseModal
            , title = text (context.i18nText I18nKeys.InviteModal_Title)
            , content =
                div []
                    [ p [] [ text (context.i18nText I18nKeys.InviteModal_Message) ]
                    , div []
                        [ input
                            [ type_ "email"
                            , class "email u-full-width"
                            , name "email"
                            , placeholder "amishi@example.com"
                            , value model.email
                            , onInput (AppMsg.InviteModalMsg << EmailInput)
                            ]
                            []
                        ]
                    , case model.requestStatus of
                        Conflict invitee ->
                            div [ class "error" ]
                                [ span [ class "message" ]
                                    [ text (context.i18nText I18nKeys.InviteModal_InviteeAlreadyExists) ]
                                , span [ class "invitee" ]
                                    [ img [ class "avatar", src invitee.avatarUrl ] []
                                    , span [ class "name" ] [ text invitee.displayName ]
                                    ]
                                ]

                        _ ->
                            div [] []
                    ]
            , buttons =
                [ button
                    [ class "button button-primary"
                    , disabled (not (validateEmail model.email) || model.requestProcessing)
                    , onClick (AppMsg.InviteModalMsg SendInviteClick)
                    ]
                    [ if model.requestProcessing then
                        text ((context.i18nText I18nKeys.InviteModal_Sending) ++ "...")
                      else
                        text (context.i18nText I18nKeys.InviteModal_SendInvite)
                    ]
                ]
            }
