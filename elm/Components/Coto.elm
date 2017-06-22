module Components.Coto exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Utils exposing (onClickWithoutPropagation)
import App.Types exposing (Coto, CotoId, Cotonoma, CotonomaKey, isPostedInCotonoma)
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
      
      
type alias BodyConfig msg =
    { openCoto : msg
    , openTraversal : Maybe (CotoId -> msg)
    , cotonomaClick : CotonomaKey -> msg
    , markdown : String -> Html msg
    }
        

bodyDiv : Graph -> BodyConfig msg -> Coto -> Html msg
bodyDiv graph config coto = 
    div [ class "coto-body" ]
        [ span [ class "coto-tools" ]
            [ case config.openTraversal of
                Nothing -> span [] []
                Just openTraversal ->
                    if App.Graph.member coto.id graph then
                        a [ class "tool-button traverse-coto"
                          , title "Open coto traversal"
                          , onClickWithoutPropagation (openTraversal coto.id)
                          ] 
                          [ i [ class "material-icons" ] [ text "open_in_new" ] ]
                    else
                        span [] []
             , a [ class "tool-button open-coto"
                 , title "Open coto view"
                 , onClickWithoutPropagation config.openCoto
                 ] 
                 [ i [ class "material-icons" ] [ text "settings" ] ]
             ]
        , if coto.asCotonoma then
            div [ class "coto-as-cotonoma" ]
                [ a [ href ("/cotonomas/" ++ coto.cotonomaKey)
                    , onClickWithoutPropagation (config.cotonomaClick coto.cotonomaKey)
                    ]
                    [ i [ class "material-icons" ] [ text "exit_to_app" ]
                    , span [ class "cotonoma-name" ] [ text coto.content ]
                    ]
                ]
          else 
            config.markdown coto.content 
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

            
