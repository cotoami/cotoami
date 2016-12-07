module App exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (on, keyCode, onFocus, onBlur, onInput, onMouseDown)
import Keyboard exposing (..)
import Dom
import Dom.Scroll
import Task
import Json.Decode as Json
import String
import Markdown
import Keys exposing (ctrl, meta, enter)

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
  = NoOp
  | KeyDown KeyCode
  | KeyUp KeyCode
  | FocusNewPostEditor
  | BlurNewPostEditor
  | InputNewPost String
  | Post
  | KeyDownInNewPostEditor KeyCode
  
update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    NoOp ->
      model ! []

    KeyDown key -> 
      if key == ctrl.keyCode || key == meta.keyCode then
        ({ model | ctrlDown = True }, Cmd.none)
      else
        (model, Cmd.none)
        
    KeyUp key -> 
      if key == ctrl.keyCode || key == meta.keyCode then
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
      post model
      
    KeyDownInNewPostEditor key ->
      if key == enter.keyCode && model.ctrlDown then
        post model
      else
        (model, Cmd.none)

post : Model -> (Model, Cmd Msg)
post model =
  { model | posts = model.newPost :: model.posts, newPost = "" }
    ! [Task.attempt handleScrollResult (Dom.Scroll.toBottom "timeline")]

handleScrollResult : Result Dom.Error () -> Msg
handleScrollResult result =
  case result of
    Ok _ -> NoOp
    Err _ -> NoOp
            
            
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
  div [id "app"] [
    div [id "app-header"] [
      div [class "title"] [
        i [class "material-icons"] [text "home"]
      ]
    ],
    div [id "app-body", class "container"] [
      div [id "timeline-column", class (timelineClass model)] [
        div [id "timeline"] 
          (List.map (\post -> div [class "post"] [Markdown.toHtml [class "content"] post]) (List.reverse model.posts)),
        div [id "new-post"] [
          div [class "toolbar", hidden (not model.editingNewPost)] [
            span [class "user"] [
              i [class "material-icons"] [text "perm_identity"],
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
  ]

timelineClass : Model -> String
timelineClass model =
  if model.editingNewPost then "editing" else ""

onKeyDown : (Int -> msg) -> Attribute msg
onKeyDown tagger =
  on "keydown" (Json.map tagger keyCode)
