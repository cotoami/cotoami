module Util.EventUtil
    exposing
        ( onClickWithoutPropagation
        , onLinkButtonClick
        , onKeyDown
        , onLoad
        )

import Html exposing (Attribute)
import Html.Events exposing (..)
import Json.Decode as Decode


onClickWithoutPropagation : msg -> Attribute msg
onClickWithoutPropagation message =
    onNoValueEvent "click"
        message
        { stopPropagation = True
        , preventDefault = False
        }


onLinkButtonClick : msg -> Attribute msg
onLinkButtonClick message =
    onNoValueEvent "click"
        message
        { stopPropagation = True
        , preventDefault = True
        }


onNoValueEvent : String -> msg -> Html.Events.Options -> Attribute msg
onNoValueEvent eventName message options =
    onWithOptions eventName options (Decode.succeed message)


onKeyDown : (Int -> msg) -> Attribute msg
onKeyDown tagger =
    on "keydown" (Decode.map tagger keyCode)


onLoad : msg -> Attribute msg
onLoad message =
    on "load" (Decode.succeed message)
