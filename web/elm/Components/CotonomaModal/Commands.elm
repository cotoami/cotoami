module Components.CotonomaModal.Commands exposing (..)

import Json.Encode as Encode
import Http
import App.Types exposing (Cotonoma)
import Components.Timeline.Model exposing (decodePost)
import Components.CotonomaModal.Messages exposing (..)


postCotonoma : Maybe Cotonoma -> Int -> String -> Cmd Msg
postCotonoma maybeCotonoma postId name =
    Http.send Posted 
        <| Http.post 
            "/api/cotonomas" 
            (Http.jsonBody (encodeCotonoma maybeCotonoma postId name)) 
            decodePost

    
encodeCotonoma : Maybe Cotonoma -> Int -> String -> Encode.Value
encodeCotonoma maybeCotonoma postId name =
    Encode.object 
        [ ("cotonoma", 
            (Encode.object 
                [ ("cotonoma_id"
                  , case maybeCotonoma of
                        Nothing -> Encode.null 
                        Just cotonoma -> Encode.int cotonoma.id
                  )
                , ("postId", Encode.int postId)
                , ("name", Encode.string name)
                ]
            )
          )
        ]
