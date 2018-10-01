module App.Views.AppHeaderMsg exposing (Msg(..))


type Msg
    = OpenSigninModal
    | OpenProfileModal
    | ClearQuickSearchInput
    | QuickSearchInput String
    | NavigationToggle
