module Util.Keyboard.Event
    exposing
        ( KeyboardEvent
        , decodeKeyboardEvent
        , considerKeyboardEvent
        , KeyCode
        , decodeKeyCode
        , decodeKey
        )

{-|
    Original version: https://github.com/Gizra/elm-keyboard-event
-}

import Json.Decode exposing (Decoder, map, map7, int, field, oneOf, andThen, maybe, succeed, fail, bool, string)
import Util.Keyboard.Key exposing (Key, fromCode)
import String


{-| A type alias for `Int`.
-}
type alias KeyCode =
    Int


{-| Decodes `keyCode`, `which` or `charCode` from a [keyboard event][keyboard-event]
to get a numeric code for the key that was pressed.
[keyboard-event]: https://developer.mozilla.org/en-US/docs/Web/API/KeyboardEvent
-}
decodeKeyCode : Decoder KeyCode
decodeKeyCode =
    oneOf
        [ field "keyCode" decodeNonZero
        , field "which" decodeNonZero
        , field "charCode" decodeNonZero
          -- In principle, we should always get some code, so instead
          -- of making this a Maybe, we succeed with 0.
        , succeed 0
        ]


{-| Decodes an Int, but only if it's not zero.
-}
decodeNonZero : Decoder Int
decodeNonZero =
    andThen
        (\code ->
            if code == 0 then
                fail "code was zero"
            else
                succeed code
        )
        int


{-| Decodes the `key` field from a [keyboard event][keyboard-event].
Results in `Nothing` if the `key` field is not present, or blank.
[keyboard-event]: https://developer.mozilla.org/en-US/docs/Web/API/KeyboardEvent
-}
decodeKey : Decoder (Maybe String)
decodeKey =
    field "key" string
        |> andThen
            (\key ->
                if String.isEmpty key then
                    fail "empty key"
                else
                    succeed key
            )
        |> maybe


{-| A representation of a [keyboard event][keyboard-event].
The `key` field may or may not be present, depending on the listener ("keydown"
vs. "keypress" vs. "keyup"), browser, and key pressed (character key vs.
special key). If not present, it will be `Nothing` here.
The `keyCode` is normalized by `decodeKeyboardEvent` to use whichever of
`which`, `keyCode` or `charCode` is provided, and made type-safe via
`Keyboard.Key`
(see the excellent [SwiftsNamesake/proper-keyboard][proper-keyboard-pkg] for
further manipulation of a `Key`).
[keyboard-event]: https://developer.mozilla.org/en-US/docs/Web/API/KeyboardEvent
[proper-keyboard-pkg]: http://package.elm-lang.org/packages/SwiftsNamesake/proper-keyboard/latest
-}
type alias KeyboardEvent =
    { altKey : Bool
    , ctrlKey : Bool
    , key : Maybe String
    , keyCode : Key
    , metaKey : Bool
    , repeat : Bool
    , shiftKey : Bool
    }


{-| Decodes a `KeyboardEvent` from a [keyboard event][keyboard-event].
[keyboard-event]: https://developer.mozilla.org/en-US/docs/Web/API/KeyboardEvent
-}
decodeKeyboardEvent : Decoder KeyboardEvent
decodeKeyboardEvent =
    map7 KeyboardEvent
        (field "altKey" bool)
        (field "ctrlKey" bool)
        decodeKey
        (map fromCode decodeKeyCode)
        (field "metaKey" bool)
        (field "repeat" bool)
        (field "shiftKey" bool)


{-| You provide a function which, given a `KeyboardEvent`, turns it into a
message your `update` function can handle. You get back a `Decoder` for those
messages.
When your function returns `Nothing`, the decoder will fail. This means that
the event will simply be ignored -- that is, it will not reach your `update`
function at all.
Essentially, this allows you to filter keyboard events inside the decoder
itself, rather than in the `update` function. Whether this is a good idea or
not will depend on your scenario.
-}
considerKeyboardEvent : (KeyboardEvent -> Maybe msg) -> Decoder msg
considerKeyboardEvent func =
    andThen
        (\event ->
            case func event of
                Just msg ->
                    succeed msg

                Nothing ->
                    fail "Ignoring keyboard event"
        )
        decodeKeyboardEvent
