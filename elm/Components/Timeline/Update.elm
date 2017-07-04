module Components.Timeline.Update exposing (..)

import Json.Decode as Decode
import Keys exposing (ctrl, meta, enter)
import Utils exposing (isBlank, send)
import App.Types exposing (Cotonoma, Context)
import App.Channels exposing (Payload, decodePayload)
import Components.Timeline.Model exposing (Post, defaultPost, Model, decodePost)
import Components.Timeline.Messages exposing (..)
import Components.Timeline.Commands exposing (..)


update : Context -> Msg -> Model -> ( Model, Cmd Msg )
update context msg model =
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
            if key == enter.keyCode && context.ctrlDown && (not (isBlank model.newContent)) then
                post context.clientId context.cotonoma model
            else
                model ! []
                
        Post ->
            post context.clientId context.cotonoma model
                
        Posted (Ok response) ->
            { model | posts = setCotoSaved response model.posts } ! []
          
        Posted (Err _) ->
            model ! []
            
        PostOpen post ->
            model ! []
            
        CotonomaClick key ->
            model ! []
            
        PostPushed payload ->
            case Decode.decodeValue (decodePayload "post" decodePost) payload of
                Ok decodedPayload ->
                    handlePushedPost context.clientId decodedPayload model
                Err err ->
                    model ! []
                    
        CotonomaPushed post ->
            model ! []
            
        SelectCoto cotoId ->
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
        ( newModel, newPost ) = 
            postContent clientId maybeCotonoma False model.newContent model
    in
        newModel !
            [ scrollToBottom NoOp
            , Components.Timeline.Commands.post clientId maybeCotonoma Posted newPost
            ]
    

postContent : String -> Maybe Cotonoma -> Bool -> String -> Model -> ( Model, Post )
postContent clientId maybeCotonoma asCotonoma content model =
    let
        postId = model.postIdCounter + 1
        newPost = 
            { defaultPost
            | postId = Just postId
            , content = content
            , asCotonoma = asCotonoma
            , postedIn = maybeCotonoma
            }
    in
        ( { model 
          | posts = newPost :: model.posts
          , postIdCounter = postId
          , newContent = ""
          } 
        , newPost
        )


setCotoSaved : Post -> List Post -> List Post
setCotoSaved apiResponse posts =
    List.map 
        (\post ->
            if post.postId == apiResponse.postId then
                { post
                | cotoId = apiResponse.cotoId
                , cotonomaKey = apiResponse.cotonomaKey
                }
            else 
                post
        ) 
        posts
    
