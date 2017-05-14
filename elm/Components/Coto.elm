module Components.Coto exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Utils exposing (onClickWithoutPropagation)
import App.Types exposing (Coto, Cotonoma, CotonomaKey, isPostedInCotonoma)
import App.Graph exposing (Graph, pinned, hasChildren)


headerDiv : (CotonomaKey -> msg) -> Maybe Cotonoma -> Graph -> Coto -> Html msg
headerDiv cotonomaClick maybeCotonoma graph coto =
    div 
        [ class "coto-header" ]
        [ case coto.postedIn of
            Nothing -> span [] []
            Just postedIn ->
                if not (isPostedInCotonoma maybeCotonoma coto) then
                    a 
                        [ class "posted-in"
                        , onClickWithoutPropagation (cotonomaClick postedIn.key) 
                        ] 
                        [ text postedIn.name ]
                else
                    span [] []
        , if pinned coto.id graph then
            i [ class "pinned fa fa-thumb-tack"
              , (attribute "aria-hidden" "true") 
              ] []
          else
              span [] []
        ]


subCotosButtonDiv : Graph -> Maybe Int -> Html msg
subCotosButtonDiv graph maybeCotoId =
    case maybeCotoId of
        Nothing ->
            div [] []
        Just cotoId -> 
            if hasChildren cotoId graph then
                div [ class "sub-cotos-button" ]
                    [ a []
                        [ i [ class "material-icons" ] [ text "more_horiz" ]
                        ]
                    ]
            else
                div [] []
