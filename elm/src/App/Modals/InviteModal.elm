module App.Modals.InviteModal exposing (Model, defaultModel, update, view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import Http
import Json.Decode as Decode
import Util.StringUtil exposing (validateEmail)
import Util.Modal as Modal
import App.Messages as AppMsg exposing (Msg(CloseModal))
import App.Modals.InviteModalMsg as InviteModalMsg exposing (Msg(..))


type RequestStatus
    = None
    | Approved
    | Rejected


type alias Model =
    { email : String
    , requestProcessing : Bool
    , requestStatus : RequestStatus
    }


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
                , requestStatus = Approved
              }
            , Cmd.none
            )

        SendInviteDone (Err _) ->
            ( { model
                | requestProcessing = False
                , requestStatus = Rejected
              }
            , Cmd.none
            )


sendInvite : String -> Cmd InviteModalMsg.Msg
sendInvite email =
    let
        url =
            "/api/amishis/invite/" ++ email
    in
        Http.send SendInviteDone (Http.get url Decode.string)


view : Model -> Html AppMsg.Msg
view model =
    modalConfig model
        |> Just
        |> Modal.view "invite-modal"


modalConfig : Model -> Modal.Config AppMsg.Msg
modalConfig model =
    if model.requestStatus == Approved then
        { closeMessage = CloseModal
        , title = "Invite an amishi"
        , content =
            div [] [ text ("Your invitation has been sent to: " ++ model.email) ]
        , buttons =
            [ button [ class "button", onClick CloseModal ] [ text "OK" ] ]
        }
    else
        { closeMessage = CloseModal
        , title = "Invite an amishi"
        , content =
            div []
                [ p [] [ text "Enter an email address to send an invitation." ]
                , Html.form [ name "signin" ]
                    [ div []
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
                    , if model.requestStatus == Rejected then
                        div [ class "errors" ]
                            [ span [ class "rejected" ] [ text "The amishi already exists." ]
                            ]
                      else
                        div [] []
                    ]
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
