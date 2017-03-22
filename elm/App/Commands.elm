module App.Commands exposing (..)

import Http
import Json.Decode as Decode
import App.Types 
    exposing 
        ( Amishi
        , Cotonoma
        , CotonomaKey
        , decodeSession
        , decodeAmishi
        , decodeCotonoma
        )
import App.Messages exposing (..)
import Components.Timeline.Model exposing (decodePost)


fetchSession : Cmd Msg
fetchSession =
    Http.send SessionFetched (Http.get "/api/session" decodeSession)


fetchRecentCotonomas : Cmd Msg
fetchRecentCotonomas =
    Http.send RecentCotonomasFetched 
        <| Http.get "/api/cotonomas"
        <| Decode.list decodeCotonoma
        

fetchCotonomas : Maybe Cotonoma -> Cmd Msg
fetchCotonomas maybeCotonoma =
    let
        url = case maybeCotonoma of
            Nothing -> "/api/cotonomas"
            Just cotonoma -> "/api/cotonomas?cotonoma_id=" ++ (toString cotonoma.id)
    in
        Http.send CotonomasFetched 
            <| Http.get url
            <| Decode.list decodeCotonoma
    

fetchAmishi : (Result Http.Error Amishi -> msg) -> String -> Cmd msg
fetchAmishi msg email =
    Http.send msg
        <| Http.get ("/api/amishis/email/" ++ email)
        <| decodeAmishi
    
  
fetchCotonoma : CotonomaKey -> Cmd Msg
fetchCotonoma key =
    let
        url = "/api/cotonomas/" ++ key ++ "/cotos"
    in
        Http.send CotonomaFetched
            <| Http.get url
            <| Decode.map3 (,,)
                (Decode.field "cotonoma" decodeCotonoma)
                (Decode.field "members" (Decode.list decodeAmishi))
                (Decode.field "cotos" (Decode.list decodePost))


deleteCoto : Int -> Cmd Msg
deleteCoto cotoId =
    Http.send 
        CotoDeleted
        (Http.request
          { method = "DELETE"
          , headers = []
          , url = "/api/cotos/" ++ toString(cotoId)
          , body = Http.emptyBody
          , expect = Http.expectString 
          , timeout = Nothing
          , withCredentials = False
          }
        )
          
