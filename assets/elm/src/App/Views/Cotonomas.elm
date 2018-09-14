module App.Views.Cotonomas exposing (..)

import Html exposing (..)
import Html.Keyed
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Utils.EventUtil exposing (onLinkButtonClick, onClickWithoutPropagation)
import App.Types.Coto exposing (Cotonoma)
import App.Types.Graph exposing (Graph)
import App.Messages exposing (Msg(..))
import App.Submodels.Context exposing (Context)
import App.Views.Coto exposing (defaultActionConfig)


view : Context a -> Graph -> String -> List Cotonoma -> Html Msg
view context graph title cotonomas =
    Html.Keyed.node
        "div"
        [ class "cotonomas" ]
        (List.map
            (\cotonoma ->
                ( toString cotonoma.id
                , cotonomaDiv context graph title cotonoma
                )
            )
            cotonomas
        )


cotonomaDiv : Context a -> Graph -> String -> Cotonoma -> Html Msg
cotonomaDiv context graph listTitle cotonoma =
    let
        elementId =
            listTitle ++ cotonoma.cotoId

        inCotonoma =
            context.cotonoma
                |> Maybe.map (\current -> current.id == cotonoma.id)
                |> Maybe.withDefault False
    in
        div
            [ classList
                [ ( "coto-as-cotonoma", True )
                , ( "element-focus", Just elementId == context.elementFocus )
                , ( "coto-focus", Just cotonoma.cotoId == context.cotoFocus )
                , ( "selected", App.Submodels.Context.isSelected (Just cotonoma.cotoId) context )
                , ( "in", inCotonoma )
                , ( "not-active", not (App.Types.Coto.revisedBefore cotonoma) )
                ]
            , onClickWithoutPropagation (CotoClick elementId cotonoma.cotoId)
            , onMouseEnter (CotoMouseEnter elementId cotonoma.cotoId)
            , onMouseLeave (CotoMouseLeave elementId cotonoma.cotoId)
            ]
            [ div [ class "cotonoma-link" ]
                [ if inCotonoma then
                    App.Views.Coto.cotonomaLabel cotonoma.owner cotonoma
                  else
                    App.Views.Coto.cotonomaLink context CotonomaClick cotonoma.owner cotonoma
                ]
            , div [ class "touch-space-to-open-tools" ] []
            , App.Types.Coto.toCoto cotonoma
                |> (\coto ->
                        App.Views.Coto.toolButtonsSpan
                            context
                            graph
                            Nothing
                            { defaultActionConfig
                                | editCoto = Nothing
                                , addCoto = Nothing
                            }
                            elementId
                            coto
                   )
            ]
