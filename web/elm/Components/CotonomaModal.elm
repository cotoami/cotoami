module Components.CotonomaModal exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import Json.Encode as Encode
import Http
import Utils exposing (isBlank)
import Modal
import Components.Timeline.Model as Timeline
import Components.Timeline.Commands exposing (decodeCoto, scrollToBottom)
import Components.Timeline.Update
import Components.Timeline.Messages exposing (Msg(CotoPosted))


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
    = NoOp
    | Close
    | NameInput String
    | Post
    | Posted (Result Http.Error Timeline.Coto)


update : Msg -> Timeline.Model -> Model -> ( Model, Timeline.Model, Cmd Msg )
update msg timeline model =
    case msg of
        NoOp ->
            ( model, timeline, Cmd.none )
            
        Close ->
            ( { model | open = False }, timeline, Cmd.none )
            
        NameInput content ->
            ( { model | name = content }, timeline, Cmd.none )
            
        Post ->
            let
                postId = timeline.postIdCounter + 1
                defaultCoto = Timeline.defaultCoto
                newCoto = 
                    { defaultCoto
                    | id = Nothing
                    , postId = Just postId
                    , content = model.name
                    , asCotonoma = True
                    }
            in
                ( { model 
                  | open = False
                  , name = "" 
                  }
                , { timeline 
                  | cotos = newCoto :: timeline.cotos
                  , postIdCounter = postId
                  }
                , Cmd.batch
                    [ scrollToBottom NoOp
                    , postCotonoma postId model.name 
                    ]
                )
                
        Posted (Ok savedCoto) ->
            let
                ( newTimeline, _ ) =
                    Components.Timeline.Update.update 
                        (CotoPosted (Ok savedCoto)) timeline False
            in
                ( model, newTimeline, Cmd.none )
          
        Posted (Err _) ->
            ( model, timeline, Cmd.none )


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
            , onClick Post 
            ] 
            [ text "Create" ]
        ]
    }
    

nameMaxlength : Int
nameMaxlength = 30


validateName : String -> Bool
validateName string =
    not (isBlank string) && (String.length string) <= nameMaxlength
    

postCotonoma : Int -> String -> Cmd Msg
postCotonoma postId name =
    Http.send 
        Posted 
        (Http.post "/api/cotonomas" (Http.jsonBody (encodeCotonoma postId name)) decodeCoto)

    
encodeCotonoma : Int -> String -> Encode.Value
encodeCotonoma postId name =
    Encode.object 
        [ ("cotonoma", 
            (Encode.object 
                [ ("postId", Encode.int postId)
                , ("name", Encode.string name)
                ]
            )
          )
        ]
