module Components.Coto exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Utils exposing (onClickWithoutPropagation)
import App.Types exposing (Coto, CotoId, Cotonoma, CotonomaKey, isPostedInCotonoma)
import App.Graph exposing (Graph, pinned, hasChildren, Traversal, Traverse)


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
                        , href ("/cotonomas/" ++ postedIn.key)
                        , onClickWithoutPropagation (cotonomaClick postedIn.key) 
                        ] 
                        [ text postedIn.name ]
                else
                    span [] []
        , if pinned coto.id graph then
            i [ class "pinned fa fa-thumb-tack"
              , (attribute "aria-hidden" "true") 
              ] []
          else if App.Graph.member coto.id graph then
            i [ class "connected fa fa-share-alt"
              , (attribute "aria-hidden" "true") 
              ] []
          else
              span [] []
        ]


openTraversalButtonDiv : (CotoId -> msg) -> Maybe CotoId -> Graph -> Html msg
openTraversalButtonDiv buttonClick maybeCotoId graph =
    case maybeCotoId of
        Nothing ->
            div [] []
        Just cotoId -> 
            if hasChildren cotoId graph then
                div [ class "sub-cotos-button" ]
                    [ a [ onClickWithoutPropagation (buttonClick cotoId) ]
                        [ i [ class "material-icons" ] [ text "more_horiz" ]
                        ]
                    ]
            else
                div [] []


traverseButtonDiv : (Traverse -> msg) -> Int -> CotoId -> Traversal -> Graph-> Html msg
traverseButtonDiv buttonClick index cotoId traversal graph =
    if hasChildren cotoId graph then
        div [ class "sub-cotos-button" ]
            [ a [ onClickWithoutPropagation (buttonClick (Traverse traversal index cotoId)) ]
                [ i [ class "material-icons" ] [ text "more_horiz" ]
                ]
            ]
    else
        div [] []
            
