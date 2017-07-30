module Components.CotonomaModal.Model exposing (..)

import App.Types exposing (Session)
import App.Types.Amishi exposing (Amishi)

type Member = SignedUp Amishi | NotYetSignedUp String


type alias Model =
    { open : Bool
    , name : String
    , memberEmail : String
    , memberEmailValid : Bool
    , membersLoading : Bool
    , members : List Member
    }


initModel : Model
initModel =
    { open = False
    , name = ""
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
        email = case member of
            SignedUp amishi -> amishi.email
            NotYetSignedUp email -> email

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
            (\member -> case member of
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
            (\member -> case member of
                SignedUp amishi ->
                    amishi.email == email
                NotYetSignedUp memberEmail ->
                    memberEmail == email
            )
            model.members
