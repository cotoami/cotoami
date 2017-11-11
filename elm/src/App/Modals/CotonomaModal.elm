module App.Modals.CotonomaModal
    exposing
        ( Model
        , defaultModel
        , updateRequestStatus
        , update
        , view
        )

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import Http exposing (Error(..))
import Util.Modal as Modal
import App.Types.Session exposing (Session, toAmishi)
import App.Types.Coto exposing (cotonomaNameMaxlength, validateCotonomaName)
import App.Types.Context exposing (Context)
import App.Messages as AppMsg exposing (Msg(CloseModal, NoOp, PostCotonoma))
import App.Views.Coto exposing (cotonomaLabel)
import App.Modals.CotonomaModalMsg as CotonomaModalMsg exposing (Msg(..))


type alias Model =
    { name : String
    , requestProcessing : Bool
    , requestStatus : RequestStatus
    }


type RequestStatus
    = None
    | Conflict
    | Rejected


defaultModel : Model
defaultModel =
    { name = ""
    , requestProcessing = False
    , requestStatus = None
    }


updateRequestStatus : Http.Error -> Model -> ( Model, Int )
updateRequestStatus error model =
    let
        ( requestStatus, postId ) =
            case error of
                BadStatus response ->
                    let
                        postId =
                            String.toInt response.body
                                |> Result.withDefault 0
                    in
                        if response.status.code == 409 then
                            ( Conflict, postId )
                        else
                            ( Rejected, postId )

                _ ->
                    ( Rejected, 0 )
    in
        ( { model
            | requestProcessing = False
            , requestStatus = requestStatus
          }
        , postId
        )


update : Context -> Session -> CotonomaModalMsg.Msg -> Model -> ( Model, Cmd CotonomaModalMsg.Msg )
update context session msg model =
    case msg of
        CotonomaModalMsg.NoOp ->
            ( model, Cmd.none )

        NameInput content ->
            ( { model | name = content }, Cmd.none )


view : Context -> Model -> Html AppMsg.Msg
view context model =
    Modal.view
        "cotonoma-modal"
        (Maybe.map (\session -> modalConfig session context model) context.session)


modalConfig : Session -> Context -> Model -> Modal.Config AppMsg.Msg
modalConfig session context model =
    { closeMessage = CloseModal
    , title = text "Cotonoma"
    , content =
        div []
            [ p []
                [ text
                    ("A cotonoma is a unit of shared space where everyone can "
                        ++ "see the content and join the conversation."
                    )
                ]
            , context.cotonoma
                |> Maybe.map
                    (\cotonoma ->
                        div [ class "target-cotonoma" ]
                            [ label [] [ text "Post to" ]
                            , cotonomaLabel cotonoma.owner cotonoma.name
                            ]
                    )
                |> Maybe.withDefault (div [] [])
            , div []
                [ label [] [ text "Name" ]
                , input
                    [ type_ "text"
                    , class "u-full-width"
                    , name "name"
                    , placeholder "Name"
                    , maxlength cotonomaNameMaxlength
                    , value model.name
                    , onInput (AppMsg.CotonomaModalMsg << NameInput)
                    ]
                    []
                ]
            , case model.requestStatus of
                Conflict ->
                    div [ class "error" ]
                        [ span [ class "message" ]
                            [ text "You already have this cotonoma." ]
                        ]

                Rejected ->
                    div [ class "error" ]
                        [ span [ class "message" ]
                            [ text "An unexpected error has occurred." ]
                        ]

                _ ->
                    div [] []
            ]
    , buttons =
        [ button
            [ class "button button-primary"
            , disabled
                (not (validateCotonomaName model.name)
                    || model.requestProcessing
                )
            , onClick PostCotonoma
            ]
            [ if model.requestProcessing then
                text "Creating..."
              else
                text "Create"
            ]
        ]
    }
