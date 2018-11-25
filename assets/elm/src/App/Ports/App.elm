port module App.Ports.App
    exposing
        ( setUnreadStateInTitle
        )


port setUnreadStateInTitle : Bool -> Cmd msg
