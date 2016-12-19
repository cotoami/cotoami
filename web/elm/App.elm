module App exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (on, onClick, keyCode, onFocus, onBlur, onInput, onMouseDown)
import Keyboard exposing (..)
import Dom
import Dom.Scroll
import Task
import Json.Decode as Decode
import Json.Encode as Encode
import Markdown
import Keys exposing (ctrl, meta, enter)
import Http
import Modal
import Utils exposing (isBlank, validateEmail)

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
    , showSigninModal : Bool
    , signinEmail : String
    , signinRequestProcessing : Bool
    , signinRequestDone : Bool
    }


initModel : Model
initModel =
    { ctrlDown = False
    , editingNewCoto = False
    , newCoto = ""
    , cotos = []
    , showSigninModal = False
    , signinEmail = ""
    , signinRequestProcessing = False
    , signinRequestDone = False
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
    | EditorFocus
    | EditorBlur
    | EditorInput String
    | EditorKeyDown KeyCode
    | Post
    | CotoPosted (Result Http.Error Coto)
    | SigninClick
    | SigninModalClose
    | SigninEmailInput String
    | SigninRequestClick
    | SigninRequestDone (Result Http.Error String)


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

        EditorFocus ->
            ( { model | editingNewCoto = True }, Cmd.none )

        EditorBlur ->
            ( { model | editingNewCoto = False }, Cmd.none )

        EditorInput content ->
            ( { model | newCoto = content }, Cmd.none )

        EditorKeyDown key ->
            if key == enter.keyCode && model.ctrlDown && (not (isBlank model.newCoto)) then
                post model
            else
                ( model, Cmd.none )
                
        Post ->
            post model
                
        CotoPosted (Ok coto) ->
            ( model, Cmd.none )
          
        CotoPosted (Err _) ->
            ( model, Cmd.none )
            
        SigninClick ->
            ( { model | showSigninModal = True }, Cmd.none )
            
        SigninModalClose ->
            ( { model | showSigninModal = False, signinRequestDone = False }, Cmd.none )
            
        SigninEmailInput content ->
            ( { model | signinEmail = content }, Cmd.none )
           
        SigninRequestClick ->
            { model | signinRequestProcessing = True }
                ! [ requestSignin model.signinEmail ]
           
        SigninRequestDone (Ok message) ->
            ( { model | signinEmail = "", signinRequestProcessing = False, signinRequestDone = True }, Cmd.none )
            
        SigninRequestDone (Err _) ->
            ( { model | signinRequestProcessing = False }, Cmd.none )


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
    
  
requestSignin : String -> Cmd Msg
requestSignin email =
    Http.send SigninRequestDone (Http.get ("/api/signin/request/" ++ email) Decode.string)



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
            , div [ class "user" ]
                [ a [ href "#", title "Sign in", onClick SigninClick ] 
                    [ i [ class "material-icons" ] [ text "perm_identity" ] ] 
                ]
            ]
        , div [ id "app-body", class "container" ]
            [ div [ id "timeline-column", class (timelineClass model) ]
                [ div [ id "timeline" ]
                    (List.map (\coto -> div [ class "coto" ] [ markdown coto.content ]) (List.reverse model.cotos))
                , div [ id "new-coto" ]
                    [ div [ class "toolbar", hidden (not model.editingNewCoto) ]
                        [ span [ class "user anonymous" ]
                            [ i [ class "material-icons" ] [ text "perm_identity" ]
                            , text "Anonymous"
                            ]
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
            ]
        , Modal.view
            (if model.showSigninModal then
                Just (signinModalConfig model)
             else
                Nothing
            )
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


signinModalConfig : Model -> Modal.Config Msg
signinModalConfig model =
    { closeMessage = SigninModalClose
    , title = "Sign in with your email"
    , content = div [ id "signin-modal-content" ]
        (if model.signinRequestDone then
            [ div [ class "sucess-message" ]
              [ div [] 
                [ strong [] [ text "Check your inbox!" ]
                , text "We just sent you an email with a link to access (or create) your Cotoami account." 
                ]
              ]
            ]
        else 
            [ p [] [ text "Cotoami doesn't use passwords. Just enter your email address and we'll send you a sign-in (or sign-up) link." ]
            , div []
              [ input 
                [ type_ "email"
                , class "u-full-width"
                , placeholder "test@example.com"
                , value model.signinEmail
                , onInput SigninEmailInput
                ] 
                [] 
              ]
            ]
        )
    , buttons = 
      [ button [ class "button", onClick SigninModalClose ] [ text "Cancel" ]
      , button 
          [ class "button button-primary"
          , disabled (not (validateEmail model.signinEmail) || model.signinRequestProcessing)
          , onClick SigninRequestClick 
          ] 
          [ if model.signinRequestProcessing then text "Sending..." else text "OK" ]
      ]
    }
