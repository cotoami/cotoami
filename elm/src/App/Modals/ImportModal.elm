module App.Modals.ImportModal exposing (Model, defaultModel, view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Util.Modal as Modal
import Util.StringUtil exposing (isBlank)
import App.Messages as AppMsg exposing (Msg(CloseModal))


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
                [ button [ class "button", onClick CloseModal ] [ text "OK" ] ]
            }

        _ ->
            { closeMessage = CloseModal
            , title = "Import cotos and connections"
            , content =
                div []
                    [ p [] [ text "Paste the content (JSON) of an exported file and click the IMPORT button." ]
                    , Html.form [ name "import" ]
                        [ textarea
                            [ class "data"
                            , value model.data
                            ]
                            []
                        ]
                    ]
            , buttons =
                [ button
                    [ class "button button-primary"
                    , disabled (isBlank model.data || model.requestProcessing)
                    ]
                    [ if model.requestProcessing then
                        text "Importing..."
                      else
                        text "Import"
                    ]
                ]
            }
