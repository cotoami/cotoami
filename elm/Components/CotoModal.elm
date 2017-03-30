module Components.CotoModal exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Modal
import App.Types exposing (Coto)
import App.Markdown


type alias Model =
    { open : Bool
    , coto : Maybe Coto
    }


initModel : Model
initModel =
    { open = False
    , coto = Nothing
    }
    

type Msg
    = Close
    | ConfirmDelete String
    | Delete Coto
    | Connect Coto
    
    
update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Close ->
            ( { model | open = False }, Cmd.none )
            
        ConfirmDelete message ->
            ( model, Cmd.none )
            
        Delete coto ->
            ( { model | open = False }, Cmd.none )
            
        Connect coto ->
            ( { model | open = False }, Cmd.none )


view : Model -> Html Msg
view model =
    Modal.view
        "coto-modal"
        (if model.open then
            case model.coto of
                Nothing -> Nothing
                Just coto -> Just (modalConfig coto model)
         else
            Nothing
        )
      

modalConfig : Coto -> Model -> Modal.Config Msg
modalConfig coto model =
    { closeMessage = Close
    , title = if coto.asCotonoma then "Cotonoma" else "Coto"
    , content = div []
        [ div [ class "coto" ]
            [ App.Markdown.markdown coto.content
            ]
        ]
    , buttons = 
        [ button 
            [ class "button"
            , onClick (Connect coto)
            ]
            [ text "Connect" ]
        , button 
            [ class "button"
            , onClick (ConfirmDelete "Are you sure you want to delete this coto?") 
            ] 
            [ text "Delete" ]
        ]
    }
