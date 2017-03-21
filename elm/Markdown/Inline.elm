-- Elm Markdown - https://github.com/pablohirafuji/elm-markdown
module Markdown.Inline exposing (..)


import Dict exposing (Dict)
import Html exposing (Html, node, text)
import Html.Attributes exposing (href, title, alt, src, attribute)
import Http exposing (encodeUri)
import Regex exposing (Regex)
import Markdown.Config as Config exposing (Elements, Options, HtmlOption(..))



----------------------------------------------------------------------
----------------------- Parser Model & Helpers -----------------------
----------------------------------------------------------------------


type alias Parser =
    { rawText : String
    , tokens  : List Token
    , matches : List Match
    , options : Options
    , refs    : References
    }


initParser : Options -> References -> String -> Parser
initParser options refs rawText  =
    { rawText = rawText
    , tokens  = []
    , matches = []
    , options = options
    , refs    = refs
    }


type alias References =
    Dict String ( String, Maybe String ) -- Label ( Url, Maybe Title )


addMatch : Parser -> Match -> Parser
addMatch model match =
    { model | matches =
        match :: model.matches
    }



----------------------------------------------------------------------
------------------------------- Parser -------------------------------
----------------------------------------------------------------------


parse : Options -> References -> String -> List Match
parse options refs rawText =
    String.trim rawText
        |> initParser options refs
        |> tokenize
        |> tokensToMatches
        |> organizeParserMatches
        |> parseText
        |> .matches


parseText : Parser -> Parser
parseText model =
    { model | matches =
        parseTextMatches model.rawText [] model.matches
    }


parseTextMatches : String -> List Match -> List Match -> List Match
parseTextMatches rawText parsedMatches matches =
    case matches of
        [] ->
            case parsedMatches of
                [] ->
                    -- No text to parse
                    if String.isEmpty rawText then
                        []

                    -- No match found
                    else
                        [ normalMatch rawText ]


                -- Add initial normal match
                Match matchModel :: _ ->
                    if matchModel.start > 0 then
                        normalMatch (String.left (matchModel.start) rawText)
                            :: parsedMatches

                    else
                        parsedMatches


        match :: matchesTail ->
            parseTextMatches rawText
                (parseTextMatch rawText match parsedMatches)
                matchesTail


parseTextMatch : String -> Match -> List Match -> List Match
parseTextMatch rawText (Match matchModel) parsedMatches =
    let
        updtMatch : Match
        updtMatch =
            Match { matchModel | matches =
                parseTextMatches matchModel.text [] matchModel.matches
            }


    in
        case parsedMatches of
            [] ->
                -- Add final normal match
                let
                    finalStr =
                        String.dropLeft matchModel.end rawText


                in
                    if String.isEmpty finalStr then
                        [ updtMatch ]


                    else
                        [ updtMatch
                        , normalMatch finalStr
                        ]


            Match matchHead :: matchesTail ->
                if matchHead.type_ == Normal then
                    updtMatch :: parsedMatches


                -- New Match
                else if matchModel.end == matchHead.start then
                    updtMatch :: parsedMatches


                -- New Match and add in between unmatched string
                else if matchModel.end < matchHead.start then
                    updtMatch
                        :: normalMatch (String.slice matchModel.end matchHead.start rawText)
                        :: parsedMatches


                -- Overlaping or inside previous Match
                else
                    parsedMatches



----------------------------------------------------------------------
-------------------------------- Match -------------------------------
----------------------------------------------------------------------


type Match
    = Match MatchModel


type alias MatchModel =
    { type_     : Type
    , start     : Int
    , end       : Int
    , textStart : Int
    , textEnd   : Int
    , text      : String
    , matches   : List Match
    }


normalMatch : String -> Match
normalMatch text =
    Match
        { type_     = Normal
        , start     = 0
        , end       = 0
        , textStart = 0
        , textEnd   = 0
        , text      = replaceEscapable text
        , matches   = []
        }


type Type
    = Normal
    | HardLineBreak
    | Code
    | Emphasis Int -- Tag length
    | Autolink ( String, String ) -- ( Text, Url )
    | Link ( String, Maybe String ) -- ( Url, Maybe Title )
    | Image ( String, Maybe String ) -- ( Src, Maybe Title )
    | Html HtmlModel


extractText : List Match -> String
extractText matches =
    let
        extract : Match -> String -> String
        extract (Match match) text =
            case match.type_ of
                Normal ->
                    text ++ match.text


                HardLineBreak ->
                    text ++ " "


                _ ->
                    text ++ extractText match.matches

    in
        List.foldl extract "" matches


organizeParserMatches : Parser -> Parser
organizeParserMatches model =
    { model | matches = organizeMatches model.matches }


organizeMatches : List Match -> List Match
organizeMatches =
    List.sortBy (\(Match match) -> match.start)
        >> List.foldl organizeMatch []
        >> List.map
            (\(Match match) -> Match
                { match | matches =
                    organizeMatches match.matches
                }
            )


organizeMatch : Match -> List Match -> List Match
organizeMatch (Match match) matches =
    case matches of
        [] ->
            [ Match match ]

        Match prevMatch :: matchesTail ->
            -- New Match
            if prevMatch.end <= match.start then
                Match match :: matches

            -- Inside previous Match
            else if prevMatch.start < match.start
                && prevMatch.end > match.end then
                    addChild prevMatch match
                        :: matchesTail

            -- Overlaping previous Match
            else
                matches


addChild : MatchModel -> MatchModel -> Match
addChild parentMatch childMatch =
    Match { parentMatch | matches =
        prepareChildMatch parentMatch childMatch
            :: parentMatch.matches
    }


prepareChildMatch : MatchModel -> MatchModel -> Match
prepareChildMatch parentMatch childMatch =
    { childMatch
        | start     = childMatch.start - parentMatch.textStart
        , end       = childMatch.end - parentMatch.textStart
        , textStart = childMatch.textStart - parentMatch.textStart
        , textEnd   = childMatch.textEnd - parentMatch.textStart
    } |> Match



----------------------------------------------------------------------
-------------------------------- Token -------------------------------
----------------------------------------------------------------------


type alias Token =
    { index   : Int
    , length  : Int
    , meaning : Meaning
    }


type Meaning
    = EmphasisTag Char
    | CodeToken Bool -- isEscaped
    | LinkOpenToken Bool -- isActive
    | ImageOpenToken
    | CharToken Char
    | RightAngleBracket Bool -- isEscaped
    | HtmlToken Bool HtmlModel -- isOpening
    | EmphasisToken Char ( Int, Int ) -- ( leftFringeRank, rightFringeRank )
    | SoftLineBreakToken
    | HardLineBreakToken



findToken : ( Token -> Bool ) -> List Token -> Maybe ( Token, List Token, List Token )
findToken isToken tokens =
    let
        search : Token -> ( Maybe Token, List Token, List Token ) -> ( Maybe Token, List Token, List Token )
        search token ( maybeToken, innerTokens, remainTokens ) =
            case maybeToken of
                Nothing ->
                    if isToken token then
                        ( Just token
                        , innerTokens
                        , []
                        )


                    else
                        ( Nothing
                        , token :: innerTokens
                        , []
                        )


                Just _ ->
                    ( maybeToken
                    , innerTokens
                    , token :: remainTokens
                    )


        return : ( Maybe Token, List Token, List Token ) -> Maybe ( Token, List Token, List Token )
        return ( maybeToken, innerTokens, remainTokens ) =
            maybeToken
                |> Maybe.map (\token ->
                        ( token
                        , List.reverse innerTokens
                        , List.reverse remainTokens
                        )
                    )


    in
        List.foldl search ( Nothing, [], [] ) tokens
            |> return


tokenPairToMatch : Parser -> ( String -> String ) -> Type -> Token -> Token -> List Token -> Match
tokenPairToMatch model processText type_ openToken closeToken innerTokens =
    let
        start = openToken.index
        end = closeToken.index + closeToken.length
        textStart = openToken.index + openToken.length
        textEnd = closeToken.index


        match : MatchModel
        match =
            { type_     = type_
            , start     = start
            , end       = end
            , textStart = textStart
            , textEnd   = textEnd
            , text      = String.slice textStart textEnd model.rawText
                            |> processText
            , matches   = []
            }


        matches : List Match
        matches =
            { model
                | tokens = innerTokens
                , matches = []
            } |> tokensToMatches
              |> .matches
              |> List.map (\(Match matchModel)
                    -> prepareChildMatch match matchModel)


    in
        Match { match | matches = matches}


tokenToMatch : Token -> Type -> Match
tokenToMatch token type_ =
    { type_     = type_
    , start     = token.index
    , end       = token.index + token.length
    , textStart = 0
    , textEnd   = 0
    , text      = ""
    , matches   = []
    } |> Match



----------------------------------------------------------------------
----------------------------- Find Tokens ----------------------------
----------------------------------------------------------------------
------------------- Scan all tokens from the string ------------------
----------------------------------------------------------------------


type alias Tokenizer =
    { index       : Int
    , lastChar    : Maybe Char
    , isEscaped   : Bool
    , remainChars : List Char
    , tokens      : List Token
    }


initTokenizer : String -> Tokenizer
initTokenizer rawText =
    { index       = 0
    , lastChar    = Nothing
    , isEscaped   = False
    , remainChars = String.toList rawText
    , tokens      = []
    }


addToken : { a | tokens : List Token } -> Token -> { a | tokens : List Token }
addToken model token =
    { model | tokens =
        token :: model.tokens
    }


filterTokens : ( Token -> Bool ) -> { a | tokens : List Token } -> { a | tokens : List Token }
filterTokens filter model =
    { model | tokens =
        List.filter filter model.tokens
    }


reverseTokens : { a | tokens : List Token } -> { a | tokens : List Token }
reverseTokens model =
    { model | tokens =
        List.reverse model.tokens
    }


tokenize : Parser -> Parser
tokenize model =
    initTokenizer model.rawText
        |> tokenizer
        |> \tokenizer -> { model | tokens = tokenizer.tokens }


tokenizer : Tokenizer -> Tokenizer
tokenizer model =
    case model.remainChars of
        [] ->
            reverseTokens model


        '\n' :: remainCharsTail ->
            if model.isEscaped then
                ( '\n', 2, remainCharsTail )
                    |> consToken
                        { model
                            | isEscaped = False
                            , index = model.index - 1 --Because of escaping
                        } HardLineBreakToken
                    |> tokenizer

            else
                ( '\n', 1, remainCharsTail )
                    |> consToken model SoftLineBreakToken
                    |> \model -> { model | isEscaped = False }
                    |> tokenizer


        '`' :: remainCharsTail ->
            ( '`', 1, remainCharsTail )
                |> sameCharCount
                |> consToken model (CodeToken model.isEscaped)
                |> \model -> { model | isEscaped = False }
                |> tokenizer


        '>' :: remainCharsTail ->
            ( '>', 1, remainCharsTail )
                |> consToken model
                    (RightAngleBracket model.isEscaped)
                |> \model -> { model | isEscaped = False }
                |> tokenizer


        char :: remainCharsTail ->
            if model.isEscaped then
                { model
                    | remainChars = remainCharsTail
                    , index = model.index + 1
                    , isEscaped = False
                    , lastChar = Just char
                } |> tokenizer

            else
                unescapedTokenizer model


unescapedTokenizer : Tokenizer -> Tokenizer
unescapedTokenizer model =
    case model.remainChars of
        [] ->
            reverseTokens model


        ' ' :: ' ' :: '\n' :: remainCharsTail ->
            ( '\n', 3, remainCharsTail )
                |> consToken model HardLineBreakToken
                |> tokenizer


        '!' :: '[' :: remainCharsTail ->
            ( '[', 2, remainCharsTail )
                |> consToken model ImageOpenToken
                |> tokenizer

        '[' :: remainCharsTail ->
            ( '[', 1, remainCharsTail )
                |> consToken model (LinkOpenToken True)
                |> tokenizer


        char :: remainCharsTail ->
            if char == '*' || char == '_' then
                ( char, 1, remainCharsTail )
                    |> sameCharCount
                    |> consFringeRankedToken model (EmphasisToken char)
                    |> tokenizer


            else if char == '<' || char == ']' then
                ( char, 1, remainCharsTail )
                    |> consToken model (CharToken char)
                    |> tokenizer


            else
                { model
                    | remainChars = remainCharsTail
                    , index = model.index + 1
                    , isEscaped = char == '\\'
                    , lastChar = Just char
                } |> tokenizer


sameCharCount : ( Char, Int, List Char ) -> ( Char, Int, List Char )
sameCharCount ( char, count, chars ) =
    case chars of
        [] ->
            ( char, count, chars )


        char_ :: remainChars ->
            if char_ == char then
                sameCharCount ( char, count + 1, remainChars )


            else
                ( char, count, chars )


consToken : Tokenizer -> Meaning -> ( Char, Int, List Char ) -> Tokenizer
consToken model meaning ( char, length, remainChars ) =
    { model
        | remainChars = remainChars
        , index       = model.index + length
        , lastChar    = Just char
        , tokens      =
            { index   = model.index
            , length  = length
            , meaning = meaning
            } :: model.tokens
    }


consFringeRankedToken : Tokenizer -> ( ( Int, Int ) -> Meaning ) -> ( Char, Int, List Char ) -> Tokenizer
consFringeRankedToken model meaning charCountRemain =
    calcFringeRank model.lastChar charCountRemain
        |> meaning
        |> \type_ -> consToken model type_ charCountRemain


calcFringeRank : Maybe Char -> ( Char, Int, List Char ) -> ( Int, Int )
calcFringeRank maybeLeft ( char, count, remainChars ) =
    ( maybeCharFringeRank maybeLeft
    , maybeCharFringeRank (List.head remainChars)
    )


maybeCharFringeRank : Maybe Char -> Int
maybeCharFringeRank maybeChar =
    maybeChar
        |> Maybe.map charFringeRank
        |> Maybe.withDefault 0


charFringeRank : Char -> Int
charFringeRank char =
    let string = String.fromChar char
    in
        if containSpace string then 0
        else if containPunctuation string then 1
        else 2


containSpace : String -> Bool
containSpace =
    Regex.contains (Regex.regex "\\s")


containPunctuation : String -> Bool
containPunctuation =
    Regex.contains (Regex.regex "[!-#%-\\*,-/:;\\?@\\[-\\]_\\{\\}]")



----------------------------------------------------------------------
------------------ Transform Tokens to Matches (TTM) -----------------
----------------------------------------------------------------------


tokensToMatches : Parser -> Parser
tokensToMatches =
    applyTTM codeAutolinkHtmlTagTTM
        >> applyTTM htmlElementTTM
        >> applyTTM linkImageTTM
        >> applyTTM emphasisTTM
        >> applyTTM lineBreakTTM


applyTTM : ( ( List Token, Parser ) -> Parser ) -> Parser -> Parser
applyTTM finderFunction model =
    finderFunction ( model.tokens, { model | tokens = [] } )


----------------------------------------------------------------------
------- Code spans, HTML tags, and autolinks Tokens To Matches -------
----------------------------------------------------------------------
---- Code spans, HTML tags, and autolinks have the same precedence ---
----------------------------------------------------------------------


codeAutolinkHtmlTagTTM : ( List Token, Parser ) -> Parser
codeAutolinkHtmlTagTTM ( tokens, model ) =
    case tokens of
        [] ->
            reverseTokens model


        token :: tokensTail ->
            case token.meaning of
                CodeToken isEscaped ->
                    model.tokens
                        |> findToken (isCodeTokenPair token)
                        |> Maybe.map (codeToMatch token model)
                        |> Maybe.withDefault (addToken model token)
                        |> (,) tokensTail
                        |> codeAutolinkHtmlTagTTM


                RightAngleBracket isEscaped ->
                    model.tokens
                        |> findToken
                            (.meaning >> (==) (CharToken '<'))
                        |> Maybe.andThen
                            (angleBracketsToMatch token
                                isEscaped model)
                        |> Maybe.withDefault model
                        |> filterTokens
                            (.meaning >> (/=) (CharToken '<'))
                        |> (,) tokensTail
                        |> codeAutolinkHtmlTagTTM


                _ ->
                    codeAutolinkHtmlTagTTM
                        ( tokensTail
                        , addToken model token
                        )



----------------------------------------------------------------------
---------------------------- Code Helpers ----------------------------
----------------------------------------------------------------------


isCodeTokenPair : Token -> Token -> Bool
isCodeTokenPair closeToken openToken =
    case openToken.meaning of
        CodeToken isEscaped ->
            -- If open token is escaped, ignore first '`'
            if isEscaped then
                openToken.length - 1 == closeToken.length

            else
                openToken.length == closeToken.length

        _ ->
            False


codeToMatch : Token -> Parser -> ( Token, List Token, List Token ) -> Parser
codeToMatch closeToken model ( openToken, _, remainTokens ) =
    let
        -- If open token is escaped, ignore first '`'
        updtOpenToken : Token
        updtOpenToken =
            if openToken.meaning == CodeToken True then
                { openToken
                    | index = openToken.index + 1
                    , length = openToken.length - 1
                }

            else
                openToken

    in
        { model
            | matches =
                tokenPairToMatch
                    model
                    cleanWhitespaces Code
                    updtOpenToken closeToken []
                        :: model.matches
            , tokens = remainTokens
        }



----------------------------------------------------------------------
-------------------------- Autolinks & HTML --------------------------
----------------------------------------------------------------------


angleBracketsToMatch : Token -> Bool -> Parser -> ( Token, List Token, List Token ) -> Maybe Parser
angleBracketsToMatch closeToken isEscaped model ( openToken, _, remainTokens ) =
    let
        tempMatch : Match
        tempMatch =
            tokenPairToMatch
                model (\s -> s) Code
                openToken closeToken []


    in
        autolinkToMatch tempMatch
            |> ifNothing (emailAutolinkToMatch tempMatch)
            |> Maybe.map (\newMatch ->
                    { model
                        | matches = newMatch :: model.matches
                        , tokens = remainTokens
                    })
            |> \maybeModel ->
                    if not isEscaped && maybeModel == Nothing then
                        htmlToToken
                            { model | tokens = remainTokens }
                            tempMatch

                    else
                        maybeModel



----------------------------------------------------------------------
-------------------------- Autolink Helpers --------------------------
----------------------------------------------------------------------


autolinkToMatch : Match -> Maybe Match
autolinkToMatch (Match match) =
    if Regex.contains urlRegex match.text then
        { match | type_ =
            Autolink ( match.text, encodeUrl match.text )
        } |> Match |> Just

    else
        Nothing


-- From http://spec.commonmark.org/dingus/commonmark.js
urlRegex : Regex
urlRegex =
    Regex.regex "^([A-Za-z][A-Za-z0-9.+\\-]{1,31}:[^<>\\x00-\\x20]*)$"


emailAutolinkToMatch : Match -> Maybe Match
emailAutolinkToMatch (Match match) =
    if Regex.contains emailRegex match.text then
        { match | type_ =
            Autolink ( match.text, "mailto:" ++ encodeUrl match.text )
        } |> Match |> Just

    else
        Nothing


-- From http://spec.commonmark.org/dingus/commonmark.js
emailRegex : Regex
emailRegex =
    Regex.regex "^([a-zA-Z0-9.!#$%&'*+\\/=?^_`{|}~\\-]+@[a-zA-Z0-9](?:[a-zA-Z0-9\\-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9\\-]{0,61}[a-zA-Z0-9])?)*)$"



----------------------------------------------------------------------
---------------------------- Html Helpers ----------------------------
----------------------------------------------------------------------


type alias HtmlModel =
    { tag : String
    , attributes : List Attribute
    }


type alias Attribute = ( String, Maybe String )


htmlToToken : Parser -> Match -> Maybe Parser
htmlToToken model (Match match) =
    case model.options.rawHtml of
        DontParse ->
            Nothing


        _ ->
            Regex.find (Regex.AtMost 1) htmlRegex match.text
                |> List.head
                |> Maybe.andThen
                    (htmlFromRegex model match)


htmlRegex : Regex
htmlRegex =
    Regex.regex "^(\\/)?([a-zA-Z][a-zA-Z0-9\\-]*)(?:\\s+([^<>]*?))?(\\/)?$"


htmlFromRegex : Parser -> MatchModel -> Regex.Match -> Maybe Parser
htmlFromRegex model match regexMatch =
    case regexMatch.submatches of
        _ :: Just "" :: _ ->
            Nothing


        maybeClose
            :: Just tag
            :: maybeAttributes
            :: maybeSelfClosing
            :: _ ->
                let
                    updateModel : List Attribute -> Parser
                    updateModel attrs =
                        { index = match.start
                        , length = match.end - match.start
                        , meaning =
                            HtmlToken
                                (maybeClose == Nothing
                                    && maybeSelfClosing == Nothing)
                                (HtmlModel tag attrs)
                        } |> addToken model


                    attributes : List Attribute
                    attributes =
                        Maybe.map applyAttributesRegex maybeAttributes
                            |> Maybe.withDefault []


                    filterAttributes : List Attribute -> List String -> List Attribute
                    filterAttributes attrs allowed =
                        List.filter (\attr ->
                                List.member (Tuple.first attr) allowed
                            ) attrs


                    noAttributesInCloseTag : Bool
                    noAttributesInCloseTag =
                        maybeClose == Nothing
                            || maybeClose /= Nothing
                            && attributes == []

                in
                    case model.options.rawHtml of
                        ParseUnsafe ->
                            if noAttributesInCloseTag then
                                Just (updateModel attributes)


                            else
                                Nothing


                        Sanitize { allowedHtmlElements , allowedHtmlAttributes } ->
                            if List.member tag allowedHtmlElements
                                && noAttributesInCloseTag then
                                    filterAttributes attributes allowedHtmlAttributes
                                        |> updateModel
                                        |> Just


                            else
                                Nothing


                        DontParse ->
                            Nothing


        _ ->
            Nothing


applyAttributesRegex : String -> List Attribute
applyAttributesRegex =
    Regex.find Regex.All htmlAttributesRegex
        >> List.filterMap attributesFromRegex


htmlAttributesRegex : Regex
htmlAttributesRegex =
    Regex.regex "([a-zA-Z:_][a-zA-Z0-9\\-_.:]*)(?: ?= ?(?:\"([^\"]*)\"|'([^']*)'|([^\\s\"'=<>`]*)))?"


attributesFromRegex : Regex.Match -> Maybe Attribute
attributesFromRegex regexMatch =
    case regexMatch.submatches of
        Just "" :: _ ->
            Nothing


        Just name
            :: maybeValueDQ -- Value inside double quotes
            :: maybeValueSQ -- Value inside single quotes
            :: maybeValueUQ -- Value unquoted
            :: _ ->
                let
                    maybeValue : Maybe String
                    maybeValue =
                        returnFirstJust
                            [ maybeValueDQ
                            , maybeValueSQ
                            , maybeValueUQ
                            ]

                in
                    Just ( name, maybeValue)


        _ ->
            Nothing


htmlElementTTM : ( List Token, Parser ) -> Parser
htmlElementTTM ( tokens, model ) =
    case tokens of
        [] ->
            reverseTokens model


        token :: tokensTail ->
            case token.meaning of
                HtmlToken isOpen htmlModel ->
                    if isVoidTag htmlModel || not isOpen then
                        tokenToMatch token (Html htmlModel)
                            |> addMatch model
                            |> (,) tokensTail
                            |> htmlElementTTM


                    else
                        tokensTail
                            |> findToken (isCloseToken htmlModel)
                            |> Maybe.map (htmlElementToMatch token model htmlModel)
                            |> Maybe.withDefault
                                (tokenToMatch token (Html htmlModel)
                                    |> addMatch model
                                    |> (,) tokensTail
                                )
                            |> htmlElementTTM


                _ ->
                    htmlElementTTM
                        ( tokensTail
                        , addToken model token
                        )


isVoidTag : HtmlModel -> Bool
isVoidTag htmlModel =
    List.member htmlModel.tag voidHtmlTags


voidHtmlTags : List String
voidHtmlTags =
    [ "area", "base", "br", "col", "embed", "hr", "img"
    , "input", "keygen", "link", "meta", "param", "source"
    , "track", "wbr" ]


isCloseToken : HtmlModel -> Token -> Bool
isCloseToken htmlModel token =
    case token.meaning of
        HtmlToken False htmlModel_ ->
            htmlModel.tag == htmlModel_.tag


        _ ->
            False


htmlElementToMatch : Token -> Parser -> HtmlModel -> ( Token, List Token, List Token ) -> ( List Token, Parser )
htmlElementToMatch openToken model htmlModel ( closeToken, innerTokens, remainTokens ) =
    ( remainTokens
    , { model | matches =
            tokenPairToMatch
                model (\s -> s) (Html htmlModel)
                openToken closeToken innerTokens
                    :: model.matches
      }
    )



----------------------------------------------------------------------
------------------ Link and images Tokens To Matches -----------------
----------------------------------------------------------------------
---- Link, reference link and images have precedence over emphasis ---
----------------------------------------------------------------------


linkImageTTM : ( List Token, Parser ) -> Parser
linkImageTTM ( tokens, model ) =
    case tokens of
        [] ->
            reverseTokens model


        token :: tokensTail ->
            case token.meaning of
                CharToken ']' ->
                    model.tokens
                        |> findToken isLinkOrImageOpenToken
                        |> Maybe.andThen
                            (linkOrImageToMatch token tokensTail model)
                        |> Maybe.withDefault ( tokensTail, model )
                        |> linkImageTTM


                _ ->
                    linkImageTTM
                        ( tokensTail
                        , addToken model token
                        )


isLinkOrImageOpenToken : Token -> Bool
isLinkOrImageOpenToken token =
    case token.meaning of
        LinkOpenToken _ -> True
        ImageOpenToken  -> True
        _               -> False


linkOrImageToMatch : Token -> List Token -> Parser -> ( Token, List Token, List Token ) -> Maybe ( List Token, Parser )
linkOrImageToMatch closeToken tokensTail model ( openToken, innerTokens, remainTokens ) =
    let
        args : Bool -> ( String, Match, Parser )
        args isLink =
            ( remainText
            , tempMatch isLink
            , { model | tokens = remainTokens }
            )


        remainText : String
        remainText =
            String.dropLeft (closeToken.index + 1) model.rawText


        tempMatch : Bool -> Match
        tempMatch isLink =
            tokenPairToMatch
                model (\s -> s)
                (if isLink then Link ("", Nothing)
                else Image ("", Nothing))
                openToken closeToken (List.reverse innerTokens)


        removeOpenToken : Maybe ( List Token, Parser )
        removeOpenToken =
            Just
                ( tokensTail
                , { model | tokens = innerTokens ++ remainTokens }
                )


        linkOpenTokenToInactive : Parser -> Parser
        linkOpenTokenToInactive model_ =
            let
                process : Token -> Token
                process token =
                    case token.meaning of
                        LinkOpenToken _ ->
                            { token | meaning = LinkOpenToken False }

                        _ ->
                            token


            in
                { model_ | tokens = List.map process model_.tokens }


    in
        case openToken.meaning of
            ImageOpenToken ->
                checkForInlineLinkOrImage (args False)
                    |> ifNothing (checkForRefLinkOrImage (args False))
                    |> Maybe.andThen checkParsedAheadOverlapping
                    |> Maybe.map (removeParsedAheadTokens tokensTail)
                    |> ifNothing removeOpenToken


            -- Active opening: set all before to inactive if found
            LinkOpenToken True ->
                checkForInlineLinkOrImage (args True)
                    |> ifNothing (checkForRefLinkOrImage (args True))
                    |> Maybe.andThen checkParsedAheadOverlapping
                    |> Maybe.map linkOpenTokenToInactive
                    |> Maybe.map (removeParsedAheadTokens tokensTail)
                    |> ifNothing removeOpenToken


            -- Inactive opening: just remove open and close tokens
            LinkOpenToken False ->
                removeOpenToken


            _ ->
                Nothing


-- Check if is overlapping previous parsed matches (code, html or autolink)
checkParsedAheadOverlapping : Parser -> Maybe Parser
checkParsedAheadOverlapping parser =
    case parser.matches of
        [] ->
            Nothing

        Match match :: remainMatches ->
            let
                overlappingMatches : List Match
                overlappingMatches =
                    List.filter
                        (\(Match testMatch) ->
                            match.end > testMatch.start
                                && match.end < testMatch.end
                        )
                        remainMatches

            in
                if List.isEmpty remainMatches
                    || List.isEmpty overlappingMatches then
                        Just parser

                else
                    Nothing


-- Remove tokens inside the parsed ahead regex match
removeParsedAheadTokens : List Token -> Parser -> ( List Token, Parser)
removeParsedAheadTokens tokensTail parser =
    case parser.matches of
        [] ->
            ( tokensTail, parser )

        Match match :: _ ->
            ( List.filter
                (\token -> token.index >= match.end )
                tokensTail
            , parser
            )



----------------------------------------------------------------------
------------------------ Inline link or image ------------------------
----------------------------------------------------------------------


checkForInlineLinkOrImage : ( String, Match, Parser ) -> Maybe Parser
checkForInlineLinkOrImage ( remainText, Match tempMatch, model ) =
    Regex.find (Regex.AtMost 1) inlineLinkOrImageRegex remainText
        |> List.head
        |> Maybe.andThen (inlineLinkOrImageRegexToMatch tempMatch model)
        |> Maybe.map (addMatch model)


inlineLinkOrImageRegex : Regex
inlineLinkOrImageRegex =
    Regex.regex ("^\\(\\s*" ++ hrefRegex ++ titleRegex ++ "\\s*\\)")


hrefRegex : String
hrefRegex =
    "(?:<([^<>"
    ++ whiteSpaceChars ++ "]*)>|([^"
    ++ whiteSpaceChars ++ "\\(\\)\\\\]*(?:\\\\.[^"
    ++ whiteSpaceChars ++ "\\(\\)\\\\]*)*))"


titleRegex : String
titleRegex =
    "(?:[" ++ whiteSpaceChars ++ "]+"
        ++ "(?:'([^'\\\\]*(?:\\\\.[^'\\\\]*)*)'|"
        ++ "\"([^\"\\\\]*(?:\\\\.[^\"\\\\]*)*)\"|"
        ++ "\\(([^\\)\\\\]*(?:\\\\.[^\\)\\\\]*)*)\\)))?"


inlineLinkOrImageRegexToMatch : MatchModel -> Parser -> Regex.Match -> Maybe Match
inlineLinkOrImageRegexToMatch matchModel model regexMatch =
    case regexMatch.submatches of
        maybeRawUrlAB       -- with angle brackets: <http://url.com>
            :: maybeRawUrlW -- without angle brackets : http://url.com
            :: maybeTitleSQ -- with single quotes: 'title'
            :: maybeTitleDQ -- with double quotes: "title"
            :: maybeTitleP  -- with parenthesis: (title)
            :: _ ->
                let
                    maybeRawUrl : Maybe String
                    maybeRawUrl =
                        returnFirstJust
                            [ maybeRawUrlAB
                            , maybeRawUrlW
                            ]


                    maybeTitle : Maybe String
                    maybeTitle =
                        returnFirstJust
                            [ maybeTitleSQ
                            , maybeTitleDQ
                            , maybeTitleP
                            ]

                    toMatch : String -> Match
                    toMatch rawUrl =
                        { matchModel
                            | type_ =
                                ( rawUrl, maybeTitle )
                                    |> prepareUrlAndTitle
                                    |> case matchModel.type_ of
                                        Image _ -> Image
                                        _       -> Link
                            , end = matchModel.end + String.length regexMatch.match
                        } |> Match


                in
                    maybeRawUrl
                        |> Maybe.map toMatch
                    

        _ ->
            Nothing


prepareUrlAndTitle : ( String, Maybe String ) -> ( String, Maybe String )
prepareUrlAndTitle ( rawUrl, maybeTitle ) =
    ( encodeUrl (replaceEscapable rawUrl)
    , Maybe.map replaceEscapable maybeTitle )



----------------------------------------------------------------------
----------------------- Reference link or image ----------------------
----------------------------------------------------------------------


checkForRefLinkOrImage : ( String, Match, Parser ) -> Maybe Parser
checkForRefLinkOrImage ( remainText, Match tempMatch, model ) =
    Regex.find (Regex.AtMost 1) refLabelRegex remainText
        |> List.head
        |> refRegexToMatch tempMatch model
        |> Maybe.map (addMatch model)


refLabelRegex : Regex
refLabelRegex =
    Regex.regex ("^\\[\\s*(" ++ insideSquareBracketRegex ++ ")\\s*\\]")


insideSquareBracketRegex : String
insideSquareBracketRegex =
    "[^\\[\\]\\\\]*(?:\\\\.[^\\[\\]\\\\]*)*"


refRegexToMatch : MatchModel -> Parser -> Maybe Regex.Match -> Maybe Match
refRegexToMatch matchModel model maybeRegexMatch =
    let
        maybeRefItem : Maybe ( String, Maybe String )
        maybeRefItem =
            Dict.get (prepareRefLabel refLabel) model.refs


        refLabel : String
        refLabel =
            maybeRegexMatch
                |> Maybe.map (.submatches >> List.head)
                |> Maybe.withDefault Nothing
                |> Maybe.withDefault Nothing
                |> Maybe.withDefault matchModel.text
                |> (\str ->
                    if String.isEmpty str then
                        matchModel.text
                    else
                        str )


        toMatch : ( String, Maybe String ) -> Match
        toMatch urlTitle =
            { matchModel
                | type_ =
                    prepareUrlAndTitle urlTitle
                        |> case matchModel.type_ of
                            Image _ -> Image
                            _       -> Link
                , end = matchModel.end + regexMatchLength
            } |> Match


        regexMatchLength : Int
        regexMatchLength =
            maybeRegexMatch
                |> Maybe.map (.match >> String.length)
                |> Maybe.withDefault 0


    in
        Maybe.map toMatch maybeRefItem
         

prepareRefLabel : String -> String
prepareRefLabel =
    cleanWhitespaces
        >> String.toLower


encodeUrl : String -> String
encodeUrl =
    Http.encodeUri
        >> Regex.replace Regex.All decodeUrlRegex
            (\match ->
                Http.decodeUri match.match
                    |> Maybe.withDefault match.match
            )


-- Decode the following chars: ;,/?:@&=+$#%
decodeUrlRegex : Regex
decodeUrlRegex =
    Regex.regex "%(?:3B|2C|2F|3F|3A|40|26|3D|2B|24|23|25)"



----------------------------------------------------------------------
--------------------- Emphasis Tokens To Matches ---------------------
----------------------------------------------------------------------


emphasisTTM : ( List Token, Parser ) -> Parser
emphasisTTM ( tokens, model ) =
    case tokens of
        [] ->
            reverseTokens model


        token :: tokensTail ->
            case token.meaning of
                EmphasisToken char ( leftRank, rightRank ) ->
                    -- Close or opening token
                    if leftRank == rightRank then
                        -- If 1) is not surrounded by whitespace and
                        --    2) is not '_' or is surronded by puntuaction
                        -- is a close or opening tag
                        if rightRank /= 0
                        && (char /= '_' || rightRank == 1)
                        then
                            -- Search for opening tag and add
                            -- match if the sum of lengths
                            -- is not multiple of 3, otherwise add
                            -- opening tag
                            model.tokens
                                |> findToken (isOpenEmphasisToken token)
                                |> Maybe.map
                                    (emphasisToMatch token
                                        tokensTail model)
                                |> Maybe.withDefault
                                    ( tokensTail
                                    , addToken model token
                                    )
                                |> emphasisTTM


                        else
                            emphasisTTM ( tokensTail, model )


                    -- Opening token
                    else if leftRank < rightRank then
                        emphasisTTM
                            ( tokensTail
                            , addToken model token
                            )


                    -- Closing token
                    else
                        model.tokens
                            |> findToken (isOpenEmphasisToken token)
                            |> Maybe.map
                                (emphasisToMatch token
                                    tokensTail model)
                            |> Maybe.withDefault ( tokensTail, model )
                            |> emphasisTTM


                _ ->
                    emphasisTTM
                        ( tokensTail
                        , addToken model token
                        )
        

isOpenEmphasisToken : Token -> Token -> Bool
isOpenEmphasisToken closeToken openToken =
    case openToken.meaning of
        EmphasisToken openChar ( openLR, openRR ) ->
            case closeToken.meaning of
                EmphasisToken closeChar ( closeLR, closeRR ) ->
                    if openChar == closeChar then
                        if openLR == openRR || closeLR == closeRR then
                            -- if the sum of lengths
                            -- is not multiple of 3
                            -- is Open emphasis
                            (closeToken.length + openToken.length) % 3 /= 0

                        else
                            True

                    else
                        False

                _ ->
                    False

        _ ->
            False


emphasisToMatch : Token -> List Token -> Parser -> ( Token, List Token, List Token ) -> ( List Token, Parser )
emphasisToMatch closeToken tokensTail model ( openToken, innerTokens, remainTokens ) =
    let
        remainLength : Int
        remainLength =
            openToken.length - closeToken.length


        ( updtOpenToken
        , updtCloseToken
        , updtRemainTokens
        , updtTokensTail ) =
            -- Perfect match
            if remainLength == 0 then
                ( openToken
                , closeToken
                , remainTokens
                , tokensTail
                )


            -- Still has opening token
            else if remainLength > 0 then
                ( { openToken
                    | index = openToken.index + remainLength
                    , length = closeToken.length
                  }
                , closeToken
                , { openToken | length = remainLength }
                    :: remainTokens
                , tokensTail
                )


            -- Still has closing token
            else
                ( openToken
                , { closeToken | length = openToken.length }
                , remainTokens
                , { closeToken
                    | index = closeToken.index + openToken.length
                    , length = -remainLength
                  } :: tokensTail
                )


        match : Match
        match =
            tokenPairToMatch
                model (\s -> s)
                (Emphasis updtOpenToken.length)
                updtOpenToken updtCloseToken
                (List.reverse innerTokens)


    in
        ( updtTokensTail
        , { model
            | matches = match :: model.matches
            , tokens = updtRemainTokens
          }
        )



----------------------------------------------------------------------
-------------------- Line Break Tokens To Matches --------------------
----------------------------------------------------------------------


lineBreakTTM : ( List Token, Parser ) -> Parser
lineBreakTTM ( tokens, model ) =
    case tokens of
        [] ->
            reverseTokens model


        token :: tokensTail ->
            if token.meaning == HardLineBreakToken
                || (token.meaning == SoftLineBreakToken
                    && model.options.softAsHardLineBreak) then
                        { model | matches =
                            tokenToMatch token HardLineBreak
                                :: model.matches
                        } |> (,) tokensTail
                          |> lineBreakTTM
                     

            else
                lineBreakTTM
                    ( tokensTail
                    , addToken model token
                    )
        


----------------------------------------------------------------------
---------------------------- Html Renderer ---------------------------
----------------------------------------------------------------------


toHtml : Elements msg -> List Match -> List (Html msg)
toHtml elements =
    List.map (matchToHtml elements)


matchToHtml : Elements msg -> Match -> Html msg
matchToHtml elements (Match match) =
    case match.type_ of
        Normal ->
            text match.text


        HardLineBreak ->
            elements.hardLineBreak


        Code ->
            elements.codeSpan match.text


        Emphasis length ->
            case length of
                1 ->
                    elements.emphasis
                        (toHtml elements match.matches)


                2 ->
                    elements.strongEmphasis
                        (toHtml elements match.matches)
                    

                _ ->
                    if length - 2 > 0 then
                        elements.strongEmphasis
                            <| flip (::) []
                            <| matchToHtml elements
                            <| Match
                                { match |
                                    type_ = Emphasis (length - 2)
                                }

                    else
                        elements.emphasis
                            (toHtml elements match.matches)


        Autolink ( text_, url ) ->
            elements.link
                { url = url
                , title = Nothing
                }
                [ text text_ ]            


        Link ( url, maybeTitle ) ->
            elements.link
                { url = url
                , title = maybeTitle
                }
                (toHtml elements match.matches)


        Image ( url, maybeTitle ) ->
            elements.image
                { alt = extractText match.matches
                , src = url
                , title = maybeTitle
                }
                    

        Html { tag, attributes } ->
            node tag
                (attributesToHtmlAttributes attributes)
                (toHtml elements match.matches)
            


attributesToHtmlAttributes : List Attribute -> List (Html.Attribute msg)
attributesToHtmlAttributes =
    List.map attributeToAttribute


attributeToAttribute : Attribute -> Html.Attribute msg
attributeToAttribute ( name, maybeValue ) =
    attribute name (Maybe.withDefault name maybeValue)



----------------------------------------------------------------------
--------------------------- General Helpers --------------------------
----------------------------------------------------------------------


whiteSpaceChars : String
whiteSpaceChars =
    " \\t\\f\\v\\r\\n"


cleanWhitespaces : String -> String
cleanWhitespaces =
    String.trim
        >> Regex.replace Regex.All
            (Regex.regex ("[" ++ whiteSpaceChars ++ "]+"))
            (\_ -> " ")


escapableRegex : Regex
escapableRegex =
    Regex.regex "(\\\\+)([!\"#$%&\\'()*+,./:;<=>?@[\\\\\\]^_`{|}~-])"


replaceEscapable : String -> String
replaceEscapable =
    Regex.replace Regex.All escapableRegex
        (\regexMatch ->
            case regexMatch.submatches of
                Just backslashes :: Just escapedStr :: _ ->
                    String.repeat
                        (String.length backslashes // 2) "\\"
                            ++ escapedStr

                _ ->
                    regexMatch.match
        )


returnFirstJust : List (Maybe a) -> Maybe a
returnFirstJust maybes =
    let
        process : Maybe a -> Maybe a -> Maybe a
        process a maybeFound =
            case maybeFound of
                Just found -> Just found
                Nothing -> a

    in
        List.foldl process Nothing maybes


ifNothing : Maybe a -> Maybe a -> Maybe a
ifNothing maybe maybe_ =
    if maybe_ == Nothing then
        maybe

    else
        maybe_
