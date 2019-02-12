module App.Markdown exposing (customHtmlBlock, customHtmlInline, extractTextFromMarkdown, markdown, markdownOptions)

import Html exposing (..)
import Html.Attributes exposing (..)
import Markdown.Block as Block exposing (Block(..))
import Markdown.Config exposing (defaultOptions)
import Markdown.Inline as Inline exposing (Inline(..))


markdown : String -> Html msg
markdown markdownText =
    markdownText
        |> Block.parse (Just markdownOptions)
        |> List.map (customHtmlBlock customHtmlInline)
        |> List.concat
        |> div [ class "content" ]


markdownOptions : Markdown.Config.Options
markdownOptions =
    { defaultOptions | softAsHardLineBreak = True }


customHtmlBlock : (Inline i -> Html msg) -> Block b i -> List (Html msg)
customHtmlBlock inlineTransformer block =
    case block of
        _ ->
            Block.defaultHtml
                (Just (customHtmlBlock inlineTransformer))
                (Just inlineTransformer)
                block


customHtmlInline : Inline i -> Html msg
customHtmlInline inline =
    case inline of
        Link url maybeTitle inlines ->
            a
                [ href url
                , title (Maybe.withDefault "" maybeTitle)
                , target "_blank"
                , rel "noopener noreferrer"
                ]
                (List.map customHtmlInline inlines)

        _ ->
            Inline.defaultHtml (Just customHtmlInline) inline


extractTextFromMarkdown : String -> List String
extractTextFromMarkdown markdownText =
    markdownText
        |> Block.parse Nothing
        |> List.map
            (\block ->
                Block.queryInlines
                    (\inline ->
                        case inline of
                            Text str ->
                                [ str ]

                            HardLineBreak ->
                                [ " " ]

                            CodeInline str ->
                                [ str ]

                            _ ->
                                [ "" ]
                    )
                    block
                    |> String.join ""
            )
