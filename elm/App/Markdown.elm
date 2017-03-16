module App.Markdown exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Markdown
import Markdown.Config exposing (defaultElements, defaultOptions)


markdown : String -> Html msg
markdown content =
    div [ class "content" ]
        <| Markdown.customHtml 
            markdownOptions
            markdownElements
            content


markdownOptions : Markdown.Config.Options
markdownOptions =
    { defaultOptions
    | softAsHardLineBreak = True
    }
    
    
markdownElements : Markdown.Config.Elements msg
markdownElements =
    { defaultElements
    | link = customLinkElement
    }


customLinkElement : Markdown.Config.Link -> List (Html msg) -> Html msg
customLinkElement link =
    a <|
        [ href link.url
        , title (Maybe.withDefault "" link.title)
        , target "_blank"
        , rel "noopener noreferrer"
        ]
