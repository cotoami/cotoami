module Components.ProfileModal exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Modal
import App.Types exposing (Session)


type alias Model =
    { open : Bool
    }


initModel : Model
initModel =
    { open = False
    }


type Msg
    = Close


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Close ->
            ( { model | open = False }, Cmd.none )


view : Maybe Session -> Model -> Html Msg
view maybeSession model =
    Modal.view
        "profile-modal"
        (case maybeSession of
            Nothing -> Nothing
            Just session ->
                (if model.open then
                    Just (modalConfig session model)
                 else
                    Nothing
                )
        )


modalConfig : Session -> Model -> Modal.Config Msg
modalConfig session model =
    { closeMessage = Close
    , title = "Amishi Profile"
    , content = div []
        [ div [ class "profile container" ]
            [ div [ class "row" ]
                [ div [ class "avatar-box three columns" ]
                    [ a [ href "https://gravatar.com/", target "_blank" ]
                        [ img [ class "avatar", src session.avatarUrl ] [] ]
                    ]
                , div [ class "profile-info nine columns" ]
                    [ label [] [ text "Name" ]
                    , input
                        [ type_ "text"
                        , class "u-full-width"
                        , value session.displayName
                        , disabled True
                        ] []
                    , label [] [ text "Email Address" ]
                    , input
                        [ type_ "text"
                        , class "u-full-width"
                        , value session.email
                        , disabled True
                        ] []
                    ]
                ]
            ]
        ]
    , buttons =
        [ a [ class "button", href "/signout" ] [ text "Sign out" ]
        ]
    }
