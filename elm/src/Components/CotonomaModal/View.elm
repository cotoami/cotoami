module Components.CotonomaModal.View exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import Util.StringUtil exposing (isBlank)
import Util.Modal as Modal
import App.Types.Amishi exposing (Amishi)
import App.Types.Session exposing (Session, toAmishi)
import Components.CotonomaModal.Model exposing (..)
import Components.CotonomaModal.Messages exposing (..)


view : Maybe Session -> Model -> Html Msg
view maybeSession model =
    Modal.view
        "cotonoma-modal"
        (case maybeSession of
            Nothing -> Nothing
            Just session ->
                (if model.open then
                    Just (modalConfig session model)
                 else
                    Nothing
                )
        )


modalConfig : Session -> Model -> Modal.Config Msg
modalConfig session model =
    { closeMessage = Close
    , title = "Cotonoma"
    , content = div []
        [ div []
            [ label [] [ text "Name" ]
            , input
                [ type_ "text"
                , class "u-full-width"
                , name "name"
                , placeholder "Name"
                , maxlength nameMaxlength
                , value model.name
                , onInput NameInput
                ] []
            ]
        , memberInputDiv model
        , div
            [ classList
                [ ( "members", True )
                , ( "loading", model.membersLoading )
                ]
            ]
            [ ul [ class "members" ]
                ((memberAsAmishi True (toAmishi session)) ::
                    (List.map
                        (\member -> case member of
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
            , onClick Post
            ]
            [ text "Create" ]
        ]
    }


memberInputDiv : Model -> Html Msg
memberInputDiv model =
    div [ class "member-input" ]
        [ label [] [ text "Members" ]
        , input
            [ type_ "text"
            , class "u-full-width"
            , name "member"
            , placeholder "Email address to invite"
            , value model.memberEmail
            , onInput MemberEmailInput
            ] []
        , a
            [ classList
                [ ( "add-member", True )
                , ( "disabled", not model.memberEmailValid )
                ]
            , title "Add member"
            , if model.memberEmailValid then
                onClick AddMember
              else
                onClick NoOp
            ]
            [ i [ class "material-icons" ] [ text "add_circle_outline" ] ]
        ]


memberAsNotAmishi : String -> Html Msg
memberAsNotAmishi email =
    li [ class "not-amishi" ]
        [ i [ class "material-icons" ] [ text "perm_identity" ]
        , span [ class "email" ] [ text email ]
        , a
            [ class "remove-member"
            , onClick (RemoveMember email)
            ]
            [ i [ class "fa fa-times", (attribute "aria-hidden" "true") ] [] ]
        ]


memberAsAmishi : Bool -> Amishi -> Html Msg
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
                , onClick (RemoveMember amishi.email)
                ]
                [ i [ class "fa fa-times", (attribute "aria-hidden" "true") ] [] ]
        ]


nameMaxlength : Int
nameMaxlength = 30


validateName : String -> Bool
validateName string =
    not (isBlank string) && (String.length string) <= nameMaxlength
