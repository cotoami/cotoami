module Components.Timeline.Update exposing (..)

import Json.Decode as Decode
import Keys exposing (ctrl, meta, enter)
import Utils exposing (isBlank, send)
import App.Types exposing (Cotonoma)
import App.Channels exposing (Payload, decodePayload)
import Components.Timeline.Model exposing (Post, defaultPost, Model, decodePost)
import Components.Timeline.Messages exposing (..)
import Components.Timeline.Commands exposing (..)


update : String -> Maybe Cotonoma -> Bool -> Msg -> Model -> ( Model, Cmd Msg )
update clientId maybeCotonoma ctrlDown msg model =
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
                post clientId maybeCotonoma model
            else
                model ! []
                
        Post ->
            post clientId maybeCotonoma model
                
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
            case Decode.decodeValue (decodePayload "post" decodePost) payload of
                Ok decodedPayload ->
                    handlePushedPost clientId decodedPayload model
                Err err ->
                    model ! []
                    
        CotonomaPushed post ->
            model ! []
            
        OpenTraversal cotoId ->
            model ! []
    

handlePushedPost : String -> Payload Post -> Model -> ( Model, Cmd Msg )
handlePushedPost clientId payload model =
    if payload.clientId /= clientId then
        { model | posts = payload.body :: model.posts } ! 
            if payload.body.asCotonoma then
                [ scrollToBottom NoOp, send (CotonomaPushed payload.body) ]
            else
                [ scrollToBottom NoOp ]
    else
        model ! []
        

post : String -> Maybe Cotonoma -> Model -> ( Model, Cmd Msg )
post clientId maybeCotonoma model =
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
            , Components.Timeline.Commands.post clientId maybeCotonoma newPost
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
