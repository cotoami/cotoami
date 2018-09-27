module App.Modals.ImportModal
    exposing
        ( Model
        , initModel
        , update
        , view
        )

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import Http exposing (Error(..))
import Json.Encode as Encode
import Json.Decode as Decode
import Utils.Modal as Modal
import Utils.UpdateUtil exposing (withCmd, withoutCmd, addCmd)
import Utils.HttpUtil exposing (ClientId, httpPost)
import App.Submodels.Context exposing (Context)
import App.Ports.ImportFile exposing (ImportFile)
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
    { importFile : ImportFile
    , requestProcessing : Bool
    , requestStatus : RequestStatus
    }


type RequestStatus
    = None
    | Imported ImportResult
    | Rejected String


initModel : ImportFile -> Model
initModel importFile =
    { importFile = importFile
    , requestProcessing = False
    , requestStatus = None
    }


update : Context a -> ImportModalMsg.Msg -> Model -> ( Model, Cmd AppMsg.Msg )
update context msg model =
    case msg of
        ImportClick ->
            { model | requestProcessing = True }
                |> withCmd
                    (\model ->
                        importData
                            context.clientId
                            model.importFile.content
                    )

        ImportDone (Ok results) ->
            { model
                | requestProcessing = False
                , requestStatus = Imported results
            }
                |> withoutCmd

        ImportDone (Err error) ->
            (case error of
                BadStatus response ->
                    response.body

                _ ->
                    "Error"
            )
                |> (\message ->
                        { model
                            | requestProcessing = False
                            , requestStatus = Rejected message
                        }
                   )
                |> withoutCmd


importData : ClientId -> String -> Cmd AppMsg.Msg
importData clientId data =
    let
        requestBody =
            Http.jsonBody <|
                Encode.object [ ( "data", Encode.string data ) ]

        decodeReject =
            Decode.map2 Reject
                (Decode.field "json" Decode.string)
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
        Http.send
            (AppMsg.ImportModalMsg << ImportDone)
            (httpPost "/api/import" clientId requestBody decodeResult)


view : Maybe Model -> Html AppMsg.Msg
view maybeModel =
    maybeModel
        |> Maybe.map modalConfig
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
                    [ p [] [ text "You are about to import the cotos/connections in the file you selected." ]
                    , importFileInfoDiv model.importFile
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
                    , disabled (not model.importFile.valid || model.requestProcessing)
                    , onClick (AppMsg.ImportModalMsg ImportClick)
                    ]
                    [ if model.requestProcessing then
                        text "Importing..."
                      else
                        text "Import"
                    ]
                ]
            }


importFileInfoDiv : ImportFile -> Html AppMsg.Msg
importFileInfoDiv importFile =
    div [ class "import-file-info" ]
        [ div [ class "file-name" ] [ text importFile.fileName ]
        , div [ class "content" ]
            [ div [ class "amishi author" ]
                [ img [ class "avatar", src importFile.amishiAvatarUrl ] []
                , span [ class "name" ] [ text importFile.amishiDisplayName ]
                , span [ class "note" ]
                    [ text "(The ownership will be transferred to you.)" ]
                ]
            , div [ class "stats" ]
                [ span [ class "count" ] [ text (toString importFile.cotos) ]
                , span [ class "suffix" ] [ text "cotos" ]
                , span [ class "count" ] [ text (toString importFile.cotonomas) ]
                , span [ class "suffix" ] [ text "cotonomas" ]
                , span [ class "count" ] [ text (toString importFile.connections) ]
                , span [ class "suffix" ] [ text "connections" ]
                ]
            ]
        ]


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
    div
        [ class "reject" ]
        [ span [ class "head" ]
            [ span [ class "caption" ] [ text caption ]
            , span [ class "reason" ] [ text reject.reason ]
            ]
        , pre [ class "json" ] [ code [] [ text reject.json ] ]
        ]
