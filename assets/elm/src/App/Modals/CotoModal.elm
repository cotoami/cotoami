module App.Modals.CotoModal exposing (Model, initModel, view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Util.Modal as Modal
import Util.DateUtil
import App.Markdown
import App.Types.Coto exposing (Coto, Cotonoma, CotonomaKey)
import App.Types.Session exposing (Session)
import App.Views.Coto exposing (cotonomaLabel)
import App.Messages as AppMsg exposing (Msg(CloseModal))


type alias Model =
    { coto : Coto
    }


initModel : Coto -> Model
initModel coto =
    { coto = coto
    }


view : Maybe Session -> Maybe Model -> Html AppMsg.Msg
view maybeSession maybeModel =
    (Maybe.map2
        (\session model -> modalConfig session model)
        maybeSession
        maybeModel
    )
        |> Modal.view "coto-modal"


modalConfig : Session -> Model -> Modal.Config AppMsg.Msg
modalConfig session model =
    model.coto.asCotonoma
        |> Maybe.map (\cotonoma -> cotonomaModalConfig session model cotonoma)
        |> Maybe.withDefault (cotoModalConfig session model)


cotoModalConfig : Session -> Model -> Modal.Config AppMsg.Msg
cotoModalConfig session model =
    { closeMessage = CloseModal
    , title = text "Coto"
    , content =
        div []
            [ div [ class "coto-view" ]
                [ model.coto.summary
                    |> Maybe.map
                        (\summary ->
                            div [ class "coto-summary" ] [ text summary ]
                        )
                    |> Maybe.withDefault (div [] [])
                , App.Markdown.markdown model.coto.content
                , cotoInfo model.coto
                ]
            ]
    , buttons = []
    }


cotonomaModalConfig : Session -> Model -> Cotonoma -> Modal.Config AppMsg.Msg
cotonomaModalConfig session model cotonoma =
    { closeMessage = CloseModal
    , title = text "Cotonoma"
    , content =
        div []
            [ div [ class "cotonoma-view" ]
                [ div [ class "cotonoma" ]
                    [ cotonomaLabel model.coto.amishi cotonoma
                    ]
                , cotoInfo model.coto
                ]
            ]
    , buttons = []
    }


cotoInfo : Coto -> Html AppMsg.Msg
cotoInfo coto =
    div [ class "coto-info" ]
        [ authorSpan coto
        , text " "
        , postedAtSpan coto
        , text " "
        , postedInSpan coto
        ]


authorSpan : Coto -> Html AppMsg.Msg
authorSpan coto =
    coto.amishi
        |> Maybe.map
            (\author ->
                span [ class "amishi author" ]
                    [ span [ class "preposition" ] [ text "by" ]
                    , img [ class "avatar", src author.avatarUrl ] []
                    , span [ class "name" ] [ text author.displayName ]
                    ]
            )
        |> Maybe.withDefault (span [] [])


postedAtSpan : Coto -> Html AppMsg.Msg
postedAtSpan coto =
    span [ class "posted-at" ]
        [ span [ class "preposition" ] [ text "at" ]
        , span [ class "datetime" ]
            [ text (Util.DateUtil.format "en_us" "%Y/%m/%d %H:%M" coto.postedAt) ]
        ]


postedInSpan : Coto -> Html AppMsg.Msg
postedInSpan coto =
    coto.postedIn
        |> Maybe.map
            (\postedIn ->
                span [ class "posted-in" ]
                    [ span [ class "preposition" ] [ text "in" ]
                    , span [ class "cotonoma-name" ] [ text postedIn.name ]
                    ]
            )
        |> Maybe.withDefault (span [] [])
