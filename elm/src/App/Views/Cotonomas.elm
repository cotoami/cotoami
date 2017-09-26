module App.Views.Cotonomas exposing (..)

import Html exposing (..)
import Html.Keyed
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Util.EventUtil exposing (onLinkButtonClick, onClickWithoutPropagation)
import App.Types.Coto exposing (Cotonoma)
import App.Types.Context exposing (Context, isSelected)
import App.Messages exposing (Msg(..))
import App.Views.Coto


view : Context -> String -> List Cotonoma -> Html Msg
view context title cotonomas =
    Html.Keyed.node
        "div"
        [ class "cotonomas" ]
        (List.map
            (\cotonoma ->
                ( toString cotonoma.id
                , cotonomaDiv context title cotonoma
                )
            )
            cotonomas
        )


cotonomaDiv : Context -> String -> Cotonoma -> Html Msg
cotonomaDiv context listTitle cotonoma =
    let
        elementId =
            listTitle ++ cotonoma.cotoId
    in
        div
            [ classList
                [ ( "coto-as-cotonoma", True )
                , ( "element-focus", Just elementId == context.elementFocus )
                , ( "coto-focus", Just cotonoma.cotoId == context.cotoFocus )
                , ( "selected", isSelected (Just cotonoma.cotoId) context )
                ]
            , onClickWithoutPropagation (CotoClick elementId cotonoma.cotoId)
            , onMouseEnter (CotoMouseEnter elementId cotonoma.cotoId)
            , onMouseLeave (CotoMouseLeave elementId cotonoma.cotoId)
            ]
            [ App.Views.Coto.cotonomaLink
                CotonomaClick
                cotonoma.owner
                cotonoma.key
                cotonoma.name
            , a
                [ class "tool-button traverse-cotonoma"
                , title "Traverse from this cotonoma"
                , onLinkButtonClick (OpenTraversal cotonoma.cotoId)
                ]
                [ i [ class "material-icons" ] [ text "arrow_forward" ] ]
            ]
