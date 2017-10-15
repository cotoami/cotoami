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
import App.Modals.ImportModalMsg as ImportModalMsg
    exposing
        ( ImportResult
        , ImportCotosResult
        , ImportConnectionsResult
        , Reject
        , Msg(..)
        )


type alias Model =
    { data : String
    , requestProcessing : Bool
    , requestStatus : RequestStatus
    }


type RequestStatus
    = None
    | Imported ImportResult
    | Rejected String


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

        decodeReject =
            Decode.map2 Reject
                (Decode.field "id" Decode.string)
                (Decode.field "reason" Decode.string)

        decodeResult =
            Decode.map2 ImportResult
                (Decode.field "cotos"
                    (Decode.map4 ImportCotosResult
                        (Decode.field "inserts" Decode.int)
                        (Decode.field "updates" Decode.int)
                        (Decode.field "cotonomas" Decode.int)
                        (Decode.field "rejected" (Decode.list decodeReject))
                    )
                )
                (Decode.field "connections"
                    (Decode.map2 ImportConnectionsResult
                        (Decode.field "ok" Decode.int)
                        (Decode.field "rejected" (Decode.list decodeReject))
                    )
                )
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
        Imported result ->
            { closeMessage = CloseModal
            , title = text "Import cotos and connections"
            , content = importResultDiv result
            , buttons =
                [ a [ class "button", href "/" ] [ text "Reload browser" ]
                ]
            }

        _ ->
            { closeMessage = CloseModal
            , title = text "Import cotos and connections"
            , content =
                div []
                    [ p [] [ text "Paste the content (JSON) of an exported file and click the IMPORT button." ]
                    , div []
                        [ textarea
                            [ class "data"
                            , value model.data
                            , onInput (AppMsg.ImportModalMsg << DataInput)
                            ]
                            []
                        ]
                    , case model.requestStatus of
                        Rejected message ->
                            div [ class "error" ]
                                [ span [ class "message" ] [ text message ] ]

                        _ ->
                            div [] []
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


importResultDiv : ImportResult -> Html AppMsg.Msg
importResultDiv { cotos, connections } =
    div []
        [ div [] [ text "The data has been successfully imported: " ]
        , div [ class "import-result" ]
            [ div [ class "cotos-result" ]
                [ div [ class "result-caption" ] [ text "Cotos:" ]
                , span [ class "number" ] [ text (toString cotos.inserts) ]
                , text "inserts"
                , span [ class "number" ] [ text (toString cotos.updates) ]
                , text "updates"
                , span [ class "number" ] [ text (toString cotos.cotonomas) ]
                , text "cotonomas"
                , span [ class "number" ] [ text (List.length cotos.rejected |> toString) ]
                , text "rejected"
                ]
            , div [ class "connections-result" ]
                [ div [ class "result-caption" ] [ text "Connections:" ]
                , span [ class "number" ] [ text (toString connections.ok) ]
                , text "imported"
                , span [ class "number" ] [ text (List.length connections.rejected |> toString) ]
                , text "rejected"
                ]
            , if (List.isEmpty cotos.rejected) && (List.isEmpty connections.rejected) then
                div [] []
              else
                div [ class "rejected" ]
                    ((List.map (rejectInfoSpan "A coto rejected: ") cotos.rejected)
                        ++ (List.map (rejectInfoSpan "A connection rejected: ") connections.rejected)
                    )
            ]
        ]


rejectInfoSpan : String -> Reject -> Html AppMsg.Msg
rejectInfoSpan caption reject =
    span
        [ class "reject" ]
        [ span [ class "reject-caption" ] [ text caption ]
        , span [ class "reject-reason" ] [ text reject.reason ]
        , text ("(ID: " ++ reject.id ++ ")")
        ]
