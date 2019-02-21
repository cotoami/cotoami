module App.Modals.CotoModal exposing (Model, initModel, view)

import App.I18n.Keys as I18nKeys
import App.Markdown
import App.Messages as AppMsg exposing (Msg(CloseModal))
import App.Submodels.Context exposing (Context)
import App.Types.Coto exposing (Coto, Cotonoma, CotonomaKey)
import App.Views.Coto exposing (cotonomaLabel)
import Html exposing (..)
import Html.Attributes exposing (..)
import Utils.DateUtil
import Utils.Modal


type alias Model =
    { coto : Coto
    }


initModel : Coto -> Model
initModel coto =
    { coto = coto
    }


view : Context context -> Model -> Html AppMsg.Msg
view context model =
    model
        |> modalConfig context
        |> Utils.Modal.view "coto-modal"


modalConfig : Context context -> Model -> Utils.Modal.Config AppMsg.Msg
modalConfig context model =
    model.coto.asCotonoma
        |> Maybe.map (\cotonoma -> cotonomaModalConfig context model cotonoma)
        |> Maybe.withDefault (cotoModalConfig context model)


cotoModalConfig : Context context -> Model -> Utils.Modal.Config AppMsg.Msg
cotoModalConfig context model =
    { closeMessage = CloseModal
    , title = text (context.i18nText I18nKeys.Coto)
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


cotonomaModalConfig : Context context -> Model -> Cotonoma -> Utils.Modal.Config AppMsg.Msg
cotonomaModalConfig context model cotonoma =
    { closeMessage = CloseModal
    , title = text (context.i18nText I18nKeys.Cotonoma)
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
            [ text (Utils.DateUtil.format "en_us" "%Y/%m/%d %H:%M" coto.postedAt) ]
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
