module App.Modals.ImportModal exposing (Model, defaultModel, update, view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import Http exposing (Error(..))
import Json.Encode as Encode
import Json.Decode as Decode
import Util.Modal as Modal
import Util.StringUtil exposing (isBlank)
import Util.HttpUtil exposing (httpPost)
import App.Messages as AppMsg exposing (Msg(CloseModal))
import App.Modals.ImportModalMsg as ImportModalMsg exposing (Msg(..))


type RequestStatus
    = None
    | Imported ( Int, Int )
    | Rejected String


type alias Model =
    { data : String
    , requestProcessing : Bool
    , requestStatus : RequestStatus
    }


defaultModel : Model
defaultModel =
    { data = ""
    , requestProcessing = False
    , requestStatus = None
    }


update : ImportModalMsg.Msg -> Model -> ( Model, Cmd ImportModalMsg.Msg )
update msg model =
    case msg of
        DataInput data ->
            ( { model | data = data }, Cmd.none )

        ImportClick ->
            { model | requestProcessing = True }
                ! [ importData model.data ]

        ImportDone (Ok results) ->
            ( { model
                | data = ""
                , requestProcessing = False
                , requestStatus = Imported results
              }
            , Cmd.none
            )

        ImportDone (Err error) ->
            (case error of
                BadStatus response ->
                    response.body

                _ ->
                    "Error"
            )
                |> (\message ->
                        ( { model
                            | requestProcessing = False
                            , requestStatus = Rejected message
                          }
                        , Cmd.none
                        )
                   )


importData : String -> Cmd ImportModalMsg.Msg
importData data =
    let
        requestBody =
            Http.jsonBody <|
                Encode.object [ ( "data", Encode.string data ) ]

        decodeResult =
            Decode.map2 (,)
                (Decode.field "cotos" Decode.int)
                (Decode.field "connections" Decode.int)
    in
        Http.send ImportDone (httpPost "/api/import" requestBody decodeResult)


view : Model -> Html AppMsg.Msg
view model =
    modalConfig model
        |> Just
        |> Modal.view "import-modal"


modalConfig : Model -> Modal.Config AppMsg.Msg
modalConfig model =
    case model.requestStatus of
        Imported ( cotos, connections ) ->
            { closeMessage = CloseModal
            , title = "Import cotos and connections"
            , content =
                div []
                    [ p []
                        [ text "The data has been successfully imported: "
                        , span [ class "import-results" ]
                            [ span [ class "imported-cotos" ] [ text (toString cotos) ]
                            , text "cotos and"
                            , span [ class "imported-connections" ] [ text (toString connections) ]
                            , text "connections"
                            ]
                        ]
                    ]
            , buttons =
                [ a [ class "button" , href "/" ] [ text "Reload browser" ]
                ]
            }

        _ ->
            { closeMessage = CloseModal
            , title = "Import cotos and connections"
            , content =
                div []
                    [ p [] [ text "Paste the content (JSON) of an exported file and click the IMPORT button." ]
                    , Html.form [ name "import" ]
                        [ div []
                            [ textarea
                                [ class "data"
                                , value model.data
                                , onInput (AppMsg.ImportModalMsg << DataInput)
                                ]
                                []
                            ]
                        , case model.requestStatus of
                            Rejected message ->
                                div [ class "errors" ]
                                    [ span [ class "rejected" ] [ text message ] ]

                            _ ->
                                div [] []
                        ]
                    ]
            , buttons =
                [ button
                    [ class "button button-primary"
                    , disabled (isBlank model.data || model.requestProcessing)
                    , onClick (AppMsg.ImportModalMsg ImportClick)
                    ]
                    [ if model.requestProcessing then
                        text "Importing..."
                      else
                        text "Import"
                    ]
                ]
            }
