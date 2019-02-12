module App.Modals.CotoModal exposing (Model, initModel, open, view)

import App.I18n.Keys as I18nKeys
import App.Markdown
import App.Messages as AppMsg exposing (Msg(CloseModal))
import App.Submodels.Context exposing (Context)
import App.Submodels.Modals exposing (Modal(CotoModal), Modals)
import App.Types.Coto exposing (Coto, Cotonoma, CotonomaKey)
import App.Types.Session exposing (Session)
import App.Views.Coto exposing (cotonomaLabel)
import Html exposing (..)
import Html.Attributes exposing (..)
import Utils.DateUtil
import Utils.Modal as Modal


type alias Model =
    { coto : Coto
    }


initModel : Coto -> Model
initModel coto =
    { coto = coto
    }


type alias WithCotoModal a =
    { a | cotoModal : Maybe Model }


open : Coto -> Modals (WithCotoModal a) -> Modals (WithCotoModal a)
open coto model =
    { model | cotoModal = Just (initModel coto) }
        |> App.Submodels.Modals.openModal CotoModal


view : Context context -> Maybe Model -> Html AppMsg.Msg
view context maybeModel =
    Maybe.map2
        (\session model -> modalConfig context session model)
        context.session
        maybeModel
        |> Modal.view "coto-modal"


modalConfig : Context context -> Session -> Model -> Modal.Config AppMsg.Msg
modalConfig context session model =
    model.coto.asCotonoma
        |> Maybe.map (\cotonoma -> cotonomaModalConfig context session model cotonoma)
        |> Maybe.withDefault (cotoModalConfig context session model)


cotoModalConfig : Context context -> Session -> Model -> Modal.Config AppMsg.Msg
cotoModalConfig context session model =
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


cotonomaModalConfig : Context context -> Session -> Model -> Cotonoma -> Modal.Config AppMsg.Msg
cotonomaModalConfig context session model cotonoma =
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
