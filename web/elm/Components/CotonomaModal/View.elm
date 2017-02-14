module Components.CotonomaModal.View exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import Utils exposing (isBlank, validateEmail)
import Modal
import App.Types exposing (Session)
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
        , div [ class "member-input" ]
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
                    , ( "disabled", not (validateEmail model.memberEmail) )
                    ]
                , title "Add member"
                ] 
                [ i [ class "material-icons" ] [ text "add_circle_outline" ] ] 
            ]
        , div [ class "members" ]
            [ ul [ class "members" ]
                [ memberAsAmishi True session.avatarUrl session.displayName
                ]
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


memberAsNotAmishi : String -> Html Msg
memberAsNotAmishi email =
    li [ class "not-amishi" ]
        [ i [ class "material-icons" ] [ text "perm_identity" ]
        , span [ class "email" ] [ text email ]
        , a [ class "remove-member" ] 
            [ i [ class "fa fa-times", (attribute "aria-hidden" "true") ] [] ] 
        ]
        
    
memberAsAmishi : Bool -> String -> String -> Html Msg
memberAsAmishi isOwner avatarUrl name =
    li 
        [ classList
            [ ( "amishi", True )
            , ( "owner", isOwner )
            ]
        ]
        [ img [ class "avatar", src avatarUrl ] []
        , span [ class "name" ] [ text name ]
        , if isOwner then
            span [ class "owner-help" ] [ text "(owner)" ]
          else
            a [ class "remove-member" ] 
                [ i [ class "fa fa-times", (attribute "aria-hidden" "true") ] [] ] 
        ] 


nameMaxlength : Int
nameMaxlength = 30


validateName : String -> Bool
validateName string =
    not (isBlank string) && (String.length string) <= nameMaxlength
    
