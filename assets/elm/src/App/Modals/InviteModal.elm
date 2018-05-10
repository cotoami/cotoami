module App.Modals.InviteModal exposing (Model, defaultModel, update, view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import Http exposing (Error(..))
import Json.Decode as Decode
import Util.StringUtil exposing (validateEmail)
import Util.Modal as Modal
import App.Types.Amishi exposing (Amishi)
import App.Server.Amishi exposing (decodeAmishi)
import App.Messages as AppMsg exposing (Msg(CloseModal))
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


update : InviteModalMsg.Msg -> Model -> ( Model, Cmd InviteModalMsg.Msg )
update msg model =
    case msg of
        EmailInput content ->
            ( { model | email = content }, Cmd.none )

        SendInviteClick ->
            { model | requestProcessing = True }
                ! [ sendInvite model.email ]

        SendInviteDone (Ok _) ->
            ( { model
                | email = ""
                , requestProcessing = False
                , requestStatus = Approved model.email
              }
            , Cmd.none
            )

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
                        ( { model
                            | requestProcessing = False
                            , requestStatus = Conflict invitee
                          }
                        , Cmd.none
                        )
                    )
                |> Maybe.withDefault
                    ( { model
                        | requestProcessing = False
                        , requestStatus = Rejected
                      }
                    , Cmd.none
                    )


sendInvite : String -> Cmd InviteModalMsg.Msg
sendInvite email =
    Http.send SendInviteDone <|
        Http.get ("/api/invite/" ++ email) Decode.string


view : Model -> Html AppMsg.Msg
view model =
    modalConfig model
        |> Just
        |> Modal.view "invite-modal"


modalConfig : Model -> Modal.Config AppMsg.Msg
modalConfig model =
    case model.requestStatus of
        Approved acceptedEmail ->
            { closeMessage = CloseModal
            , title = text "Invite an amishi"
            , content =
                div []
                    [ p []
                        [ text ("Your invitation has been sent to: ")
                        , span [ class "accepted-email" ] [ text acceptedEmail ]
                        ]
                    ]
            , buttons =
                [ button [ class "button", onClick CloseModal ] [ text "OK" ] ]
            }

        _ ->
            { closeMessage = CloseModal
            , title = text "Invite an amishi"
            , content =
                div []
                    [ p [] [ text "Enter an email address to send an invitation." ]
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
                                [ span [ class "message" ] [ text "The amishi already exists: " ]
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
                        text "Sending..."
                      else
                        text "Send an invite"
                    ]
                ]
            }
