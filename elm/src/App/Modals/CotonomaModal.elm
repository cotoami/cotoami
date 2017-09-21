module App.Modals.CotonomaModal
    exposing
        ( Model
        , defaultModel
        , setDefaultMembers
        , update
        , view
        )

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import Util.StringUtil exposing (isBlank, validateEmail)
import Util.Modal as Modal
import Util.HtmlUtil exposing (faIcon)
import App.Types.Amishi exposing (Amishi)
import App.Types.Session exposing (Session, toAmishi)
import App.Types.Coto exposing (Member(..))
import App.Types.Context exposing (Context)
import App.Server.Amishi exposing (fetchAmishi)
import App.Messages as AppMsg exposing (Msg(CloseModal, NoOp, PostCotonoma))
import App.Modals.CotonomaModalMsg as CotonomaModalMsg exposing (Msg(..))


type alias Model =
    { name : String
    , memberEmail : String
    , memberEmailValid : Bool
    , membersLoading : Bool
    , members : List Member
    }


defaultModel : Model
defaultModel =
    { name = ""
    , memberEmail = ""
    , memberEmailValid = False
    , membersLoading = False
    , members = []
    }


setDefaultMembers : Session -> List Amishi -> Model -> Model
setDefaultMembers session amishis model =
    List.foldl
        (\amishi model ->
            addMember session (SignedUp amishi) model
        )
        { model | members = [] }
        amishis


addMember : Session -> Member -> Model -> Model
addMember session member model =
    let
        email =
            case member of
                SignedUp amishi ->
                    amishi.email

                NotYetSignedUp email ->
                    email

        members =
            if (containsMember session model email) then
                model.members
            else
                member :: model.members
    in
        { model
            | members = members
            , membersLoading = False
            , memberEmail = ""
            , memberEmailValid = False
        }


removeMember : String -> Model -> Model
removeMember email model =
    { model
        | members =
            List.filter
                (\member ->
                    case member of
                        SignedUp amishi ->
                            amishi.email /= email

                        NotYetSignedUp memberEmail ->
                            memberEmail /= email
                )
                model.members
    }


containsMember : Session -> Model -> String -> Bool
containsMember session model email =
    if (session.email == email) then
        True
    else
        List.any
            (\member ->
                case member of
                    SignedUp amishi ->
                        amishi.email == email

                    NotYetSignedUp memberEmail ->
                        memberEmail == email
            )
            model.members


update : CotonomaModalMsg.Msg -> Session -> Context -> Model -> ( Model, Cmd CotonomaModalMsg.Msg )
update msg session context model =
    case msg of
        CotonomaModalMsg.NoOp ->
            ( model, Cmd.none )

        NameInput content ->
            ( { model | name = content }, Cmd.none )

        MemberEmailInput memberEmail ->
            ( { model
                | memberEmail = memberEmail
                , memberEmailValid = validateEmail memberEmail
              }
            , Cmd.none
            )

        AddMember ->
            ( { model | membersLoading = True }
            , fetchAmishi AmishiFetched model.memberEmail
            )

        AmishiFetched (Ok amishi) ->
            ( addMember session (SignedUp amishi) model
            , Cmd.none
            )

        AmishiFetched (Err _) ->
            ( addMember session (NotYetSignedUp model.memberEmail) model
            , Cmd.none
            )

        RemoveMember email ->
            ( removeMember email model
            , Cmd.none
            )


view : Maybe Session -> Model -> Html AppMsg.Msg
view maybeSession model =
    Modal.view
        "cotonoma-modal"
        (case maybeSession of
            Nothing ->
                Nothing

            Just session ->
                Just (modalConfig session model)
        )


modalConfig : Session -> Model -> Modal.Config AppMsg.Msg
modalConfig session model =
    { closeMessage = CloseModal
    , title = "Cotonoma"
    , content =
        div []
            [ div []
                [ label [] [ text "Name" ]
                , input
                    [ type_ "text"
                    , class "u-full-width"
                    , name "name"
                    , placeholder "Name"
                    , maxlength nameMaxlength
                    , value model.name
                    , onInput (AppMsg.CotonomaModalMsg << NameInput)
                    ]
                    []
                ]
            , memberInputDiv model
            , div
                [ classList
                    [ ( "members", True )
                    , ( "loading", model.membersLoading )
                    ]
                ]
                [ ul [ class "members" ]
                    ((memberAsAmishi True (toAmishi session))
                        :: (List.map
                                (\member ->
                                    case member of
                                        SignedUp amishi ->
                                            memberAsAmishi False amishi

                                        NotYetSignedUp email ->
                                            memberAsNotAmishi email
                                )
                                model.members
                           )
                    )
                ]
            ]
    , buttons =
        [ button
            [ class "button button-primary"
            , disabled (not (validateName model.name))
            , onClick PostCotonoma
            ]
            [ text "Create" ]
        ]
    }


memberInputDiv : Model -> Html AppMsg.Msg
memberInputDiv model =
    div [ class "member-input" ]
        [ label [] [ text "Members" ]
        , input
            [ type_ "text"
            , class "u-full-width"
            , name "member"
            , placeholder "Email address to invite"
            , value model.memberEmail
            , onInput (AppMsg.CotonomaModalMsg << MemberEmailInput)
            ]
            []
        , a
            [ classList
                [ ( "add-member", True )
                , ( "disabled", not model.memberEmailValid )
                ]
            , title "Add member"
            , if model.memberEmailValid then
                onClick (AppMsg.CotonomaModalMsg AddMember)
              else
                onClick AppMsg.NoOp
            ]
            [ i [ class "material-icons" ] [ text "add_circle_outline" ] ]
        ]


memberAsNotAmishi : String -> Html AppMsg.Msg
memberAsNotAmishi email =
    li [ class "not-amishi" ]
        [ i [ class "material-icons" ] [ text "perm_identity" ]
        , span [ class "email" ] [ text email ]
        , a
            [ class "remove-member"
            , onClick (AppMsg.CotonomaModalMsg (RemoveMember email))
            ]
            [ faIcon "times" Nothing ]
        ]


memberAsAmishi : Bool -> Amishi -> Html AppMsg.Msg
memberAsAmishi isOwner amishi =
    li
        [ classList
            [ ( "amishi", True )
            , ( "owner", isOwner )
            ]
        ]
        [ img [ class "avatar", src amishi.avatarUrl ] []
        , span [ class "name" ] [ text amishi.displayName ]
        , if isOwner then
            span [ class "owner-help" ] [ text "(owner)" ]
          else
            a
                [ class "remove-member"
                , onClick (AppMsg.CotonomaModalMsg (RemoveMember amishi.email))
                ]
                [ faIcon "times" Nothing ]
        ]


nameMaxlength : Int
nameMaxlength =
    30


validateName : String -> Bool
validateName string =
    not (isBlank string) && (String.length string) <= nameMaxlength
