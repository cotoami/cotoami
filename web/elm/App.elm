module App exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (on, keyCode, onFocus, onBlur, onInput, onMouseDown)
import Keyboard exposing (..)
import Dom
import Dom.Scroll
import Task
import Json.Decode as Decode
import Json.Encode as Encode
import String
import Markdown
import Keys exposing (ctrl, meta, enter)
import Http


main : Program Never Model Msg
main =
    Html.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }



-- MODEL

type alias Coto =
    { content : String
    }


type alias Model =
    { ctrlDown : Bool
    , editingNewCoto : Bool
    , newCoto : String
    , cotos : List Coto
    }


initModel : Model
initModel =
    { ctrlDown = False
    , editingNewCoto = False
    , newCoto = ""
    , cotos = []
    }


init : ( Model, Cmd Msg )
init =
    ( initModel, fetchCotos )



-- UPDATE


type Msg
    = NoOp
    | Cotos (Result Http.Error (List Coto))
    | KeyDown KeyCode
    | KeyUp KeyCode
    | FocusInput
    | BlurInput
    | InputText String
    | Post
    | KeyDownInInput KeyCode
    | CotoPosted (Result Http.Error Coto)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            model ! []
            
        Cotos (Ok cotos) ->
            ( { model | cotos = cotos }, Cmd.none )
            
        Cotos (Err _) ->
            ( model, Cmd.none )

        KeyDown key ->
            if key == ctrl.keyCode || key == meta.keyCode then
                ( { model | ctrlDown = True }, Cmd.none )
            else
                ( model, Cmd.none )

        KeyUp key ->
            if key == ctrl.keyCode || key == meta.keyCode then
                ( { model | ctrlDown = False }, Cmd.none )
            else
                ( model, Cmd.none )

        FocusInput ->
            ( { model | editingNewCoto = True }, Cmd.none )

        BlurInput ->
            ( { model | editingNewCoto = False }, Cmd.none )

        InputText content ->
            ( { model | newCoto = content }, Cmd.none )

        Post ->
            post model

        KeyDownInInput key ->
            if key == enter.keyCode && model.ctrlDown then
                post model
            else
                ( model, Cmd.none )
                
        CotoPosted (Ok coto) ->
            ( model, Cmd.none )
          
        CotoPosted (Err _) ->
            ( model, Cmd.none )


post : Model -> ( Model, Cmd Msg )
post model =
    { model | cotos = (Coto model.newCoto) :: model.cotos, newCoto = "" }
        ! [ Task.attempt handleScrollResult (Dom.Scroll.toBottom "timeline") 
          , postCoto (Coto model.newCoto)
          ]


handleScrollResult : Result Dom.Error () -> Msg
handleScrollResult result =
    case result of
        Ok _ ->
            NoOp

        Err _ ->
            NoOp


fetchCotos : Cmd Msg
fetchCotos =
    Http.send Cotos (Http.get "/api/cotos" (Decode.list decodeCoto))
  

postCoto : Coto -> Cmd Msg
postCoto coto =
    Http.send CotoPosted (Http.post "/api/cotos" (Http.jsonBody (encodeCoto coto)) decodeCoto)


decodeCoto : Decode.Decoder Coto
decodeCoto =
    Decode.map Coto
        (Decode.field "content" Decode.string)


encodeCoto : Coto -> Encode.Value
encodeCoto coto =
    Encode.object [("coto", 
      (Encode.object [("content", Encode.string coto.content)])
    )]
    


-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Keyboard.downs KeyDown
        , Keyboard.ups KeyUp
        ]



-- VIEW


view : Model -> Html Msg
view model =
    div [ id "app" ]
        [ div [ id "app-header" ]
            [ div [ class "title" ]
                [ i [ class "material-icons" ] [ text "home" ]
                ]
            ]
        , div [ id "app-body", class "container" ]
            [ div [ id "timeline-column", class (timelineClass model) ]
                [ div [ id "timeline" ]
                    (List.map (\coto -> div [ class "coto" ] [ Markdown.toHtml [ class "content" ] coto.content ]) (List.reverse model.cotos))
                , div [ id "new-coto" ]
                    [ div [ class "toolbar", hidden (not model.editingNewCoto) ]
                        [ span [ class "user" ]
                            [ i [ class "material-icons" ] [ text "perm_identity" ]
                            , text "Anonymous"
                            ]
                        , div [ class "tool-buttons" ]
                            [ button [ class "button-primary", disabled (String.isEmpty model.newCoto), onMouseDown Post ]
                                [ text "Post"
                                , span [ class "shortcut-help" ] [ text "(Ctrl + Enter)" ]
                                ]
                            ]
                        ]
                    , textarea
                        [ class "coto"
                        , placeholder "Write your idea in Markdown"
                        , value model.newCoto
                        , onFocus FocusInput
                        , onBlur BlurInput
                        , onInput InputText
                        , onKeyDown KeyDownInInput
                        ]
                        []
                    ]
                ]
            ]
        ]


timelineClass : Model -> String
timelineClass model =
    if model.editingNewCoto then
        "editing"
    else
        ""


onKeyDown : (Int -> msg) -> Attribute msg
onKeyDown tagger =
    on "keydown" (Decode.map tagger keyCode)
