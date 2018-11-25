port module App.Ports.App
    exposing
        ( updateUnreadStateInTitle
        )

import App.Submodels.Context exposing (Context)


port setUnreadStateInTitle : Bool -> Cmd msg


updateUnreadStateInTitle : Context context -> Cmd msg
updateUnreadStateInTitle context =
    setUnreadStateInTitle
        (App.Submodels.Context.anyUnreadCotos context)
