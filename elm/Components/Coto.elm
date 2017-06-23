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
      
      
type alias BodyModel =
    { cotoId : Maybe CotoId
    , content : String
    , asCotonoma : Bool
    , cotonomaKey : CotonomaKey
    }
    
    
type alias BodyConfig msg =
    { openCoto : msg
    , openTraversal : Maybe (CotoId -> msg)
    , cotonomaClick : CotonomaKey -> msg
    , markdown : String -> Html msg
    }


bodyDiv : Graph -> BodyConfig msg -> BodyModel -> Html msg
bodyDiv graph config model = 
    div [ class "coto-body" ]
        [ (case model.cotoId of
            Nothing -> span [] []
            Just cotoId -> cotoToolsSpan graph config cotoId
          )
        , if model.asCotonoma then
            div [ class "coto-as-cotonoma" ]
                [ a [ href ("/cotonomas/" ++ model.cotonomaKey)
                    , onClickWithoutPropagation (config.cotonomaClick model.cotonomaKey)
                    ]
                    [ i [ class "material-icons" ] [ text "exit_to_app" ]
                    , span [ class "cotonoma-name" ] [ text model.content ]
                    ]
                ]
          else 
              config.markdown model.content 
        ]
        
        
cotoToolsSpan : Graph -> BodyConfig msg -> CotoId -> Html msg
cotoToolsSpan graph config cotoId = 
    span [ class "coto-tools" ]
         [ case config.openTraversal of
             Nothing -> span [] []
             Just openTraversal ->
                 if App.Graph.member cotoId graph then
                    a [ class "tool-button traverse-coto"
                        , title "Open coto traversal"
                        , onClickWithoutPropagation (openTraversal cotoId)
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

            
