module Components.CotonomaModal.Commands exposing (..)

import Json.Encode as Encode
import Http
import App.Types exposing (Cotonoma)
import Components.Timeline.Model exposing (decodePost)
import Components.CotonomaModal.Model exposing (..)
import Components.CotonomaModal.Messages exposing (..)


postCotonoma : Maybe Cotonoma -> Int -> List Member -> String -> Cmd Msg
postCotonoma maybeCotonoma postId members name =
    Http.send Posted 
        <| Http.post 
            "/api/cotonomas" 
            (Http.jsonBody (encodeCotonoma maybeCotonoma postId members name)) 
            decodePost

    
encodeCotonoma : Maybe Cotonoma -> Int -> List Member -> String -> Encode.Value
encodeCotonoma maybeCotonoma postId members name =
    Encode.object 
        [ ( "cotonoma", 
            (Encode.object 
                [ ( "cotonoma_id"
                  , case maybeCotonoma of
                        Nothing -> Encode.null 
                        Just cotonoma -> Encode.int cotonoma.id
                  )
                , ( "postId", Encode.int postId )
                , ( "name", Encode.string name )
                , ( "members"
                  , Encode.list (members |> List.map (\m -> encodeMember m)) 
                  )
                ]
            )
          )
        ]


encodeMember : Member -> Encode.Value
encodeMember member =
    Encode.object 
        [ case member of
            SignedUp amishi ->
                ( "amishi_id", Encode.int amishi.id )
            NotYetSignedUp email ->
                ( "email", Encode.string email )
        ]
  
  
