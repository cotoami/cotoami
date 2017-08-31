module Util.Keys exposing (..)

import Dict exposing (Dict)
import Keyboard exposing (KeyCode)


type Modifier = Shift | Ctrl | Alt | Meta


modifiers : Dict KeyCode Modifier
modifiers =
    Dict.fromList
        [ ( 16, Shift )
        , ( 17, Ctrl )
        , ( 18, Alt )
        , ( 91, Meta )
        , ( 93, Meta )
        , ( 224, Meta )
        ]


isModifier : KeyCode -> Bool
isModifier keyCode =
    Dict.member keyCode modifiers


toModifier : KeyCode -> Maybe Modifier
toModifier keyCode =
    Dict.get keyCode modifiers


type alias Key =
    { keyCode : Keyboard.KeyCode
    , name : String
    }


enter : Key
enter =
    { keyCode = 13
    , name = "Enter"
    }


escape : Key
escape =
    { keyCode = 27
    , name = "Escape"
    }
