module App.Modals.InviteModal exposing
    ( Model
    , defaultModel
    , sendInit
    , update
    , view
    )

import App.Commands
import App.I18n.Keys as I18nKeys
import App.Messages as AppMsg exposing (Msg(CloseModal))
import App.Modals.InviteModalMsg as InviteModalMsg exposing (Msg(..))
import App.Server.Amishi
import App.Submodels.Context exposing (Context)
import App.Types.Amishi exposing (Amishi)
import App.Types.Session exposing (Session)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import Http exposing (Error(..))
import Json.Decode as Decode
import Utils.HtmlUtil
import Utils.Modal as Modal
import Utils.StringUtil exposing (validateEmail)
import Utils.UpdateUtil exposing (addCmd, withCmd, withoutCmd)


type alias Model =
    { email : String
    , invitees : Maybe (List Amishi)
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
    , invitees = Nothing
    , requestProcessing = False
    , requestStatus = None
    }


canInvite : Context context -> Model -> Bool
canInvite context model =
    context.session
        |> Maybe.map
            (\session ->
                session.amishi.inviteLimit
                    |> Maybe.map
                        (\limit ->
                            model.invitees
                                |> Maybe.map
                                    (\invitees ->
                                        List.length invitees < limit
                                    )
                                |> Maybe.withDefault False
                        )
                    |> Maybe.withDefault True
            )
        |> Maybe.withDefault False


sendInit : Cmd AppMsg.Msg
sendInit =
    AppMsg.InviteModalMsg Init
        |> App.Commands.sendMsg


update : InviteModalMsg.Msg -> Model -> ( Model, Cmd AppMsg.Msg )
update msg model =
    case msg of
        Init ->
            ( model
            , App.Server.Amishi.fetchInvitees
                (AppMsg.InviteModalMsg << InviteesFetched)
            )

        InviteesFetched (Ok invitees) ->
            { model | invitees = Just invitees } |> withoutCmd

        InviteesFetched (Err error) ->
            model |> withoutCmd

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
                |> Maybe.map (Decode.decodeString App.Server.Amishi.decodeAmishi)
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
    context.session
        |> Maybe.map (\session -> modalConfig context session model)
        |> Modal.view "invite-modal"


modalConfig : Context context -> Session -> Model -> Modal.Config AppMsg.Msg
modalConfig context session model =
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
                            , disabled (not (canInvite context model))
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
                                , inviteeSpan invitee
                                ]

                        _ ->
                            Utils.HtmlUtil.none
                    , invitesRemainingDiv context session model
                    , inviteesDiv model
                    ]
            , buttons =
                [ button
                    [ class "button button-primary"
                    , disabled
                        (not (canInvite context model)
                            || not (validateEmail model.email)
                            || model.requestProcessing
                        )
                    , onClick (AppMsg.InviteModalMsg SendInviteClick)
                    ]
                    [ if model.requestProcessing then
                        text (context.i18nText I18nKeys.InviteModal_Sending ++ "...")

                      else
                        text (context.i18nText I18nKeys.InviteModal_SendInvite)
                    ]
                ]
            }


inviteeSpan : Amishi -> Html AppMsg.Msg
inviteeSpan invitee =
    span [ class "invitee" ]
        [ img [ class "avatar", src invitee.avatarUrl ] []
        , span [ class "name" ] [ text invitee.displayName ]
        ]


invitesRemainingDiv : Context context -> Session -> Model -> Html AppMsg.Msg
invitesRemainingDiv context session model =
    Maybe.map2
        (\limit invitees ->
            let
                remaining =
                    limit - List.length invitees

                key =
                    if remaining >= 0 then
                        I18nKeys.InviteModal_InvitesRemaining remaining

                    else
                        I18nKeys.InviteModal_InvitesRemaining 0
            in
            div [ class "invites-remaining" ] [ text (context.i18nText key) ]
        )
        session.amishi.inviteLimit
        model.invitees
        |> Maybe.withDefault Utils.HtmlUtil.none


inviteeItem : Amishi -> Html AppMsg.Msg
inviteeItem invitee =
    li [ class "invitee" ]
        [ inviteeSpan invitee
        , invitee.email
            |> Maybe.map (\email -> span [ class "email" ] [ text email ])
            |> Maybe.withDefault Utils.HtmlUtil.none
        ]


inviteesDiv : Model -> Html AppMsg.Msg
inviteesDiv model =
    model.invitees
        |> Maybe.map
            (\invitees ->
                if List.isEmpty invitees then
                    Utils.HtmlUtil.none

                else
                    div [ class "invitees" ]
                        [ ol [ class "invitees" ]
                            (List.map inviteeItem invitees)
                        ]
            )
        |> Maybe.withDefault Utils.HtmlUtil.none
