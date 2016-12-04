module App exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onFocus, onBlur, onInput)
import String

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
  editingNewPost : Bool,
  newPost: String,
  posts : List String
}

init : (Model, Cmd Msg)
init = 
  (Model False "" ["Hello", "Bye"], Cmd.none)


-- UPDATE

type Msg 
  = FocusNewPostEditor
  | BlurNewPostEditor
  | InputNewPost String
  
update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    FocusNewPostEditor ->
      ({ model | editingNewPost = True }, Cmd.none)

    BlurNewPostEditor ->
      ({ model | editingNewPost = False }, Cmd.none)
      
    InputNewPost content ->
      ({ model | newPost = content }, Cmd.none)

-- SUBSCRIPTIONS

subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.none
  

-- VIEW

view : Model -> Html Msg
view model =
  div [id "app", class "container"] [ 
    div [id "timeline-column"] [
      div [id "timeline", style [("bottom", newPostHeight model)]] 
        (List.map (\post -> div [class "post"] [text post]) model.posts),
      div [id "new-post", style [("height", newPostHeight model)]] [
        div [class "toolbar", hidden (not model.editingNewPost)] [
          button [class "button-primary", disabled (String.isEmpty model.newPost)] [text "Post"]
        ],
        textarea[class "post", onFocus FocusNewPostEditor, onBlur BlurNewPostEditor, onInput InputNewPost] []
      ]
    ]
  ]
  
newPostHeight : Model -> String
newPostHeight model =
  if model.editingNewPost then "110px" else "70px"
  
