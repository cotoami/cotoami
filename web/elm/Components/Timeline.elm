module Components.Timeline exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (on, onClick, onMouseDown, onFocus, onBlur, onInput, keyCode)
import Dom
import Dom.Scroll
import Http
import Task
import Process
import Time
import Markdown
import Json.Decode as Decode
import Json.Encode as Encode
import Keyboard exposing (..)
import Keys exposing (ctrl, meta, enter)
import Utils exposing (isBlank)
import App.Types exposing (Session)


type alias Coto =
    { content : String
    }


type alias Model =
    { editingNewCoto : Bool
    , newCoto : String
    , cotos : List Coto
    }


initModel : Model
initModel =
    { editingNewCoto = False
    , newCoto = ""
    , cotos = []
    }


type Msg
    = NoOp
    | CotosFetched (Result Http.Error (List Coto))
    | EditorFocus
    | EditorBlur
    | EditorInput String
    | EditorKeyDown KeyCode
    | Post
    | CotoPosted (Result Http.Error Coto)
    

update : Msg -> Model -> Bool -> ( Model, Cmd Msg )
update msg model ctrlDown =
    case msg of
        NoOp ->
            model ! []
            
        CotosFetched (Ok cotos) ->
            ( { model | cotos = cotos }, scrollToBottom )
            
        CotosFetched (Err _) ->
            ( model, Cmd.none )

        EditorFocus ->
            ( { model | editingNewCoto = True }, Cmd.none )

        EditorBlur ->
            ( { model | editingNewCoto = False }, Cmd.none )

        EditorInput content ->
            ( { model | newCoto = content }, Cmd.none )

        EditorKeyDown key ->
            if key == enter.keyCode && ctrlDown && (not (isBlank model.newCoto)) then
                post model
            else
                ( model, Cmd.none )
                
        Post ->
            post model
                
        CotoPosted (Ok coto) ->
            ( model, Cmd.none )
          
        CotoPosted (Err _) ->
            ( model, Cmd.none )
          

post : Model -> ( Model, Cmd Msg )
post model =
    { model | cotos = (Coto model.newCoto) :: model.cotos, newCoto = "" }
        ! [ scrollToBottom
          , postCoto (Coto model.newCoto)
          ]


scrollToBottom : Cmd Msg
scrollToBottom =
    Process.sleep (1 * Time.millisecond)
    |> Task.andThen (\n -> (Dom.Scroll.toBottom "timeline"))
    |> Task.attempt handleScrollResult 


handleScrollResult : Result Dom.Error () -> Msg
handleScrollResult result =
    case result of
        Ok _ ->
            NoOp

        Err _ ->
            NoOp


fetchCotos : Cmd Msg
fetchCotos =
    Http.send CotosFetched (Http.get "/api/cotos" (Decode.list decodeCoto))


postCoto : Coto -> Cmd Msg
postCoto coto =
    Http.send 
        CotoPosted 
        (Http.post "/api/cotos" (Http.jsonBody (encodeCoto coto)) decodeCoto)
        
        
decodeCoto : Decode.Decoder Coto
decodeCoto =
    Decode.map Coto
        (Decode.field "content" Decode.string)


encodeCoto : Coto -> Encode.Value
encodeCoto coto =
    Encode.object 
        [("coto", 
            (Encode.object [("content", Encode.string coto.content)])
         )
        ]

      
view : Model -> Maybe Session -> Html Msg
view model session =
    div [ id "timeline-column", class (timelineClass model) ]
        [ div [ id "timeline" ]
            (List.map (\coto -> div [ class "coto" ] [ markdown coto.content ]) (List.reverse model.cotos))
        , div [ id "new-coto" ]
            [ div [ class "toolbar", hidden (not model.editingNewCoto) ]
                [ (case session of
                      Nothing -> 
                          span [ class "user anonymous" ]
                              [ i [ class "material-icons" ] [ text "perm_identity" ]
                              , text "Anonymous"
                              ]
                      Just session -> 
                          span [ class "user session" ]
                              [ img [ class "avatar", src session.avatarUrl ] []
                              , span [ class "name" ] [ text session.displayName ]
                              ]
                  )
                , div [ class "tool-buttons" ]
                    [ button [ class "button-primary", disabled (isBlank model.newCoto), onMouseDown Post ]
                        [ text "Post"
                        , span [ class "shortcut-help" ] [ text "(Ctrl + Enter)" ]
                        ]
                    ]
                ]
            , textarea
                [ class "coto"
                , placeholder "Write your idea in Markdown"
                , value model.newCoto
                , onFocus EditorFocus
                , onBlur EditorBlur
                , onInput EditorInput
                , onKeyDown EditorKeyDown
                ]
                []
            ]
        ]
        
        
markdown : String -> Html msg
markdown content =
    let
        defaultOptions = Markdown.defaultOptions
    in
        Markdown.toHtmlWith 
            { defaultOptions 
            | githubFlavored = Just { tables = True, breaks = True }
            , sanitize = True
            , smartypants = True
            } 
            [ class "content" ] 
            content


timelineClass : Model -> String
timelineClass model =
    if model.editingNewCoto then
        "editing"
    else
        ""


onKeyDown : (Int -> msg) -> Attribute msg
onKeyDown tagger =
    on "keydown" (Decode.map tagger keyCode)
