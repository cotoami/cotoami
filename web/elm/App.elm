module App exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (on, keyCode, onFocus, onBlur, onInput, onMouseDown)
import Keyboard exposing (..)
import Json.Decode as Json
import String
import Markdown


main : Program Never Model Msg
main = 
  Html.program { 
    init = init, 
    view = view, 
    update = update, 
    subscriptions = subscriptions
  }


-- MODEL

type alias Model = {
  ctrlDown : Bool,
  editingNewPost : Bool,
  newPost: String,
  posts : List String
}

initModel : Model
initModel = 
  {
    ctrlDown = False,
    editingNewPost = False,
    newPost = "",
    posts = []
  }

init : (Model, Cmd Msg)
init = 
  (initModel, Cmd.none)


-- UPDATE

type Msg 
  = KeyDown KeyCode
  | KeyUp KeyCode
  | FocusNewPostEditor
  | BlurNewPostEditor
  | InputNewPost String
  | Post
  | KeyDownInNewPostEditor KeyCode
  
update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    KeyDown key -> 
      if key == 17 || key == 91 then
        ({ model | ctrlDown = True }, Cmd.none)
      else
        (model, Cmd.none)
    KeyUp key -> 
      if key == 17 || key == 91 then
        ({ model | ctrlDown = False }, Cmd.none)
      else
        (model, Cmd.none)
      
    FocusNewPostEditor ->
      ({ model | editingNewPost = True }, Cmd.none)

    BlurNewPostEditor ->
      ({ model | editingNewPost = False }, Cmd.none)
      
    InputNewPost content ->
      ({ model | newPost = content }, Cmd.none)
      
    Post ->
      ({ model | posts = model.newPost :: model.posts, newPost = "" }, Cmd.none)
      
    KeyDownInNewPostEditor key ->
      if key == 13 && model.ctrlDown then
        ({ model | posts = model.newPost :: model.posts, newPost = "" }, Cmd.none)
      else
        (model, Cmd.none)
      

-- SUBSCRIPTIONS

subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.batch [ 
    Keyboard.downs KeyDown, 
    Keyboard.ups KeyUp
  ]
  

-- VIEW

view : Model -> Html Msg
view model =
  div [id "app", class "container"] [ 
    div [id "timeline-column", class (timelineClass model)] [
      div [id "timeline"] 
        (List.map (\post -> div [class "post"] [Markdown.toHtml [class "content"] post]) (List.reverse model.posts)),
      div [id "new-post"] [
        div [class "toolbar", hidden (not model.editingNewPost)] [
          span [class "user"] [
            text "Anonymous"
          ],
          div [class "tool-buttons"] [
            button [class "button-primary", disabled (String.isEmpty model.newPost), onMouseDown Post] [
              text "Post",
              span [class "shortcut-help"] [text "(Ctrl + Enter)"]
            ]
          ]
        ],
        textarea[
          class "post", 
          placeholder "Write your idea in Markdown",
          value model.newPost, 
          onFocus FocusNewPostEditor, 
          onBlur BlurNewPostEditor, 
          onInput InputNewPost,
          onKeyDown KeyDownInNewPostEditor
        ] []
      ]
    ]
  ]

timelineClass : Model -> String
timelineClass model =
  if model.editingNewPost then "editing" else ""

onKeyDown : (Int -> msg) -> Attribute msg
onKeyDown tagger =
  on "keydown" (Json.map tagger keyCode)
