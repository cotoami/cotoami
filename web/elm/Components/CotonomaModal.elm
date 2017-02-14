module Components.CotonomaModal exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import Json.Encode as Encode
import Http
import Utils exposing (isBlank, validateEmail)
import Modal
import App.Types exposing (Cotonoma)
import Components.Timeline.Model as Timeline
import Components.Timeline.Model exposing (Post, decodePost)
import Components.Timeline.Commands exposing (scrollToBottom)
import Components.Timeline.Update
import Components.Timeline.Messages


type alias Model =
    { open : Bool
    , name : String
    , memberEmail : String
    }


initModel : Model
initModel =
    { open = False
    , name = ""
    , memberEmail = ""
    }
    

type Msg
    = NoOp
    | Close
    | NameInput String
    | MemberEmailInput String
    | Post
    | Posted (Result Http.Error Post)


update : Msg -> Maybe Cotonoma -> Timeline.Model -> Model -> ( Model, Timeline.Model, Cmd Msg )
update msg maybeCotonoma timeline model =
    case msg of
        NoOp ->
            ( model, timeline, Cmd.none )
            
        Close ->
            ( { model | open = False }, timeline, Cmd.none )
            
        NameInput content ->
            ( { model | name = content }, timeline, Cmd.none )
            
        MemberEmailInput memberEmail ->
            ( { model | memberEmail = memberEmail }, timeline, Cmd.none )
            
        Post ->
            let
                postId = timeline.postIdCounter + 1
                defaultPost = Timeline.defaultPost
                newPost = 
                    { defaultPost
                    | postId = Just postId
                    , content = model.name
                    , postedIn = maybeCotonoma
                    , asCotonoma = True
                    }
            in
                ( { model 
                  | open = False
                  , name = "" 
                  }
                , { timeline 
                  | posts = newPost :: timeline.posts
                  , postIdCounter = postId
                  }
                , Cmd.batch
                    [ scrollToBottom NoOp
                    , postCotonoma maybeCotonoma postId model.name 
                    ]
                )
                
        Posted (Ok response) ->
            let
                ( newTimeline, _ ) =
                    Components.Timeline.Update.update 
                        (Components.Timeline.Messages.Posted (Ok response)) 
                        timeline 
                        maybeCotonoma 
                        False
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
                , placeholder "Name"
                , maxlength nameMaxlength
                , value model.name
                , onInput NameInput
                ] []
            ]
        , div [ class "member-input" ]
            [ label [] [ text "Members" ]
            , input 
                [ type_ "text"
                , class "u-full-width"
                , name "member"
                , placeholder "member@example.com"
                , value model.memberEmail
                , onInput MemberEmailInput
                ] []
            , a 
                [ classList
                    [ ( "add-member", True )
                    , ( "disabled", not (validateEmail model.memberEmail) )
                    ]
                , title "Add member"
                ] 
                [ i [ class "material-icons" ] [ text "add_circle_outline" ] ] 
            ]
        , div [ class "members" ]
            [ ul [ class "members" ]
                [ li [ class "not-amishi" ]
                    [ i [ class "material-icons" ] [ text "perm_identity" ]
                    , span [ class "email" ] [ text "member1@example.com" ]
                    , a [ class "remove-member" ] 
                        [ i [ class "fa fa-times", (attribute "aria-hidden" "true") ] [] ] 
                    ]
                , li [ class "amishi" ]
                    [ img [ class "avatar", src "https://secure.gravatar.com/avatar/45c52eaf01a6b70fde670cfa900116cc" ] []
                    , span [ class "name" ] [ text "テスト太郎" ]
                    , a [ class "remove-member" ] 
                        [ i [ class "fa fa-times", (attribute "aria-hidden" "true") ] [] ] 
                    ] 
                , li [ class "amishi" ]
                    [ img [ class "avatar", src "https://secure.gravatar.com/avatar/1d413392f15b8659a825fb6bab7396a9" ] []
                    , span [ class "name" ] [ text "Daisuke Morita" ]
                    , a [ class "remove-member" ] 
                        [ i [ class "fa fa-times", (attribute "aria-hidden" "true") ] [] ] 
                    ] 
                ]
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
    

postCotonoma : Maybe Cotonoma -> Int -> String -> Cmd Msg
postCotonoma maybeCotonoma postId name =
    Http.send Posted 
        <| Http.post 
            "/api/cotonomas" 
            (Http.jsonBody (encodeCotonoma maybeCotonoma postId name)) 
            decodePost

    
encodeCotonoma : Maybe Cotonoma -> Int -> String -> Encode.Value
encodeCotonoma maybeCotonoma postId name =
    Encode.object 
        [ ("cotonoma", 
            (Encode.object 
                [ ("cotonoma_id"
                  , case maybeCotonoma of
                        Nothing -> Encode.null 
                        Just cotonoma -> Encode.int cotonoma.id
                  )
                , ("postId", Encode.int postId)
                , ("name", Encode.string name)
                ]
            )
          )
        ]
