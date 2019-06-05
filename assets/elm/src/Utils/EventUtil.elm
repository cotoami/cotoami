module Utils.EventUtil exposing
    ( ScrollPos
    , fromBottom
    , onClickWithoutPropagation
    , onKeyDown
    , onLinkButtonClick
    , onLoad
    , onScroll
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


type alias ScrollPos =
    { scrollTop : Int
    , contentHeight : Int
    , containerHeight : Int
    }


fromBottom : ScrollPos -> Int
fromBottom { scrollTop, contentHeight, containerHeight } =
    contentHeight - containerHeight - scrollTop


onScroll : (ScrollPos -> msg) -> Attribute msg
onScroll tag =
    onWithOptions "scroll"
        { preventDefault = False
        , stopPropagation = True
        }
        (Decode.map tag decodeScrollPos)


decodeScrollPos : Decode.Decoder ScrollPos
decodeScrollPos =
    Decode.map3 ScrollPos
        (Decode.at [ "target", "scrollTop" ] Decode.int)
        (Decode.at [ "target", "scrollHeight" ] Decode.int)
        (Decode.map2 Basics.max offsetHeight clientHeight)


offsetHeight : Decode.Decoder Int
offsetHeight =
    Decode.at [ "target", "offsetHeight" ] Decode.int


clientHeight : Decode.Decoder Int
clientHeight =
    Decode.at [ "target", "clientHeight" ] Decode.int
