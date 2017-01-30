module Components.CotonomaModal exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onInput)
import Utils exposing (isBlank)
import Modal


type alias Model =
    { open : Bool
    , name : String
    }


initModel : Model
initModel =
    { open = False
    , name = ""
    }
    

type Msg
    = Close
    | NameInput String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Close ->
            ( { model | open = False }, Cmd.none )
            
        NameInput content ->
            ( { model | name = content }, Cmd.none )


view : Model -> Html Msg
view model =
    Modal.view
        "cotonoma-modal"
        (if model.open then
            Just (modalConfig model)
         else
            Nothing
        )
      

modalConfig : Model -> Modal.Config Msg
modalConfig model =
    { closeMessage = Close
    , title = "Cotonoma"
    , content = div []
        [ div []
            [ label [] [ text "Name" ]
            , input 
                [ type_ "text"
                , class "u-full-width"
                , name "name"
                , maxlength nameMaxlength
                , value model.name
                , onInput NameInput
                ] []
            ]
        ]
    , buttons = 
        [ button
            [ class "button button-primary"
            , disabled (not (validateName model.name))
            ] 
            [ text "Create" ]
        ]
    }
    

nameMaxlength : Int
nameMaxlength = 30


validateName : String -> Bool
validateName string =
    not (isBlank string) && (String.length string) <= nameMaxlength
