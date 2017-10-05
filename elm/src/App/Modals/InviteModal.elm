module App.Modals.InviteModal exposing (Model, defaultModel, view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Util.StringUtil exposing (validateEmail)
import Util.Modal as Modal
import App.Messages as AppMsg exposing (Msg(CloseModal))


type alias Model =
    { email : String
    , requestProcessing : Bool
    , requestDone : Bool
    }


defaultModel : Model
defaultModel =
    { email = ""
    , requestProcessing = False
    , requestDone = False
    }


view : Model -> Html AppMsg.Msg
view model =
    modalConfig model
        |> Just
        |> Modal.view "invite-modal"


modalConfig : Model -> Modal.Config AppMsg.Msg
modalConfig model =
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
                        ]
                        []
                    ]
                ]
            ]
    , buttons =
        [ button
            [ class "button button-primary"
            , disabled (not (validateEmail model.email) || model.requestProcessing)
            ]
            [ if model.requestProcessing then
                text "Sending..."
              else
                text "Send an invite"
            ]
        ]
    }
