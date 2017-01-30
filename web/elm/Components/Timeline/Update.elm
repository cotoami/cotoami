module Components.Timeline.Update exposing (..)

import Keys exposing (ctrl, meta, enter)
import Utils exposing (isBlank)
import App.Types exposing (Cotonoma)
import Components.Timeline.Model exposing (Coto, defaultCoto, Model)
import Components.Timeline.Messages exposing (..)
import Components.Timeline.Commands exposing (..)


update : Msg -> Model -> Maybe Cotonoma -> Bool -> ( Model, Cmd Msg )
update msg model maybeCotonoma ctrlDown =
    case msg of
        NoOp ->
            model ! []
            
        CotosFetched (Ok cotos) ->
            ( { model | cotos = cotos }, scrollToBottom NoOp )
            
        CotosFetched (Err _) ->
            ( model, Cmd.none )
  
        ImageLoaded ->
            model ! [ scrollToBottom NoOp ]
            
        CotoClick cotoId ->
            ( model, Cmd.none )

        EditorFocus ->
            ( { model | editingNewCoto = True }, Cmd.none )

        EditorBlur ->
            ( { model | editingNewCoto = False }, Cmd.none )

        EditorInput content ->
            ( { model | newCotoContent = content }, Cmd.none )

        EditorKeyDown key ->
            if key == enter.keyCode && ctrlDown && (not (isBlank model.newCotoContent)) then
                post maybeCotonoma model
            else
                ( model, Cmd.none )
                
        Post ->
            post maybeCotonoma model
                
        CotoPosted (Ok savedCoto) ->
            { model 
            | cotos = 
                List.map 
                    (\c -> if c.postId == savedCoto.postId then savedCoto else c) 
                    model.cotos 
            } ! []
          
        CotoPosted (Err _) ->
            ( model, Cmd.none )
            
        CotoOpen coto ->
            ( model, Cmd.none )
            
        CotonomaClick key ->
            ( model, Cmd.none )


post : Maybe Cotonoma -> Model -> ( Model, Cmd Msg )
post maybeCotonoma model =
    let
        postId = model.postIdCounter + 1
        newCoto = 
            { defaultCoto 
            | id = Nothing
            , postId = Just postId
            , content = model.newCotoContent
            }
    in
        { model 
        | cotos = newCoto :: model.cotos
        , postIdCounter = postId
        , newCotoContent = ""
        } ! 
        [ scrollToBottom NoOp
        , postCoto maybeCotonoma newCoto
        ]
