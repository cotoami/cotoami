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
    | Delete
    
    
update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Close ->
            ( { model | open = False }, Cmd.none )
            
        ConfirmDelete message ->
            ( model, Cmd.none )
            
        Delete ->
            ( { model | open = False }, Cmd.none )


view : Model -> Html Msg
view model =
    Modal.view
        "coto-modal"
        (if model.open then
            Just (modalConfig model)
         else
            Nothing
        )
      

modalConfig : Model -> Modal.Config Msg
modalConfig model =
    { closeMessage = Close
    , title = "Coto"
    , content = div [ id "coto-modal-content" ]
        [ div [ class "coto" ]
            [ (case model.coto of
                Nothing -> div [] []
                Just coto -> App.Markdown.markdown coto.content
              )
            ]
        ]
    , buttons = 
        [ a 
            [ class "button"
            , onClick (ConfirmDelete "Are you sure you want to delete this coto?") 
            ] 
            [ text "Delete" ]
        ]
    }
