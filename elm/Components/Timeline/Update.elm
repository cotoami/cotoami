module Components.Timeline.Update exposing (..)

import Keys exposing (ctrl, meta, enter)
import Utils exposing (isBlank)
import App.Types exposing (Cotonoma)
import Components.Timeline.Model exposing (Post, defaultPost, Model)
import Components.Timeline.Messages exposing (..)
import Components.Timeline.Commands exposing (..)


update : Msg -> Model -> Maybe Cotonoma -> Bool -> ( Model, Cmd Msg )
update msg model maybeCotonoma ctrlDown =
    case msg of
        NoOp ->
            model ! []
            
        PostsFetched (Ok posts) ->
            ( { model | posts = posts, loading = False }, scrollToBottom NoOp )
            
        PostsFetched (Err _) ->
            model ! []
  
        ImageLoaded ->
            model ! [ scrollToBottom NoOp ]
            
        PostClick cotoId ->
            model ! []

        EditorFocus ->
            { model | editingNew = True } ! []

        EditorBlur ->
            { model | editingNew = False } ! []

        EditorInput content ->
            { model | newContent = content } ! []

        EditorKeyDown key ->
            if key == enter.keyCode && ctrlDown && (not (isBlank model.newContent)) then
                post maybeCotonoma model
            else
                model ! []
                
        Post ->
            post maybeCotonoma model
                
        Posted (Ok response) ->
            { model 
            | posts = List.map (\post -> setCotoSaved response post) model.posts 
            } ! []
          
        Posted (Err _) ->
            model ! []
            
        PostOpen post ->
            model ! []
            
        CotonomaClick key ->
            model ! []
            
        PostPushed payload ->
            model ! []
    

post : Maybe Cotonoma -> Model -> ( Model, Cmd Msg )
post maybeCotonoma model =
    let
        postId = model.postIdCounter + 1
        newPost = 
            { defaultPost
            | postId = Just postId
            , content = model.newContent
            , postedIn = maybeCotonoma
            }
    in
        { model 
        | posts = newPost :: model.posts
        , postIdCounter = postId
        , newContent = ""
        } ! 
        [ scrollToBottom NoOp
        , Components.Timeline.Commands.post maybeCotonoma newPost
        ]


setCotoSaved : Post -> Post -> Post
setCotoSaved response post =
    if post.postId == response.postId then
        { post
        | cotoId = response.cotoId
        , cotonomaKey = response.cotonomaKey
        }
    else 
        post
