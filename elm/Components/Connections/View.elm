module Components.Connections.View exposing (..)

import Dict
import Html exposing (..)
import Html.Keyed
import Html.Attributes exposing (..)
import Markdown
import App.Types exposing (Coto)
import App.Markdown exposing (markdownOptions, markdownElements)
import Components.Connections.Model exposing (..)
import Components.Connections.Messages exposing (..)


view : Model -> Html Msg
view model =
    div [ id "connections" ] 
        [ div [ id "column-roots", class "connections-column" ]
            [ rootConnections model ]
        , div [ id "column-traversal", class "connections-column" ]
            [ div [ class "coto" ]
                [ div [ class "content" ]
                    [ text "Kubernetes" ]
                , div [ class "sub-cotos" ]
                    [ div [ class "coto" ]
                        [ div [ class "content" ]
                            [ text "Kubernetes is an open-source platform for automating deployment, scaling, and operations of application containers across clusters of hosts, providing container-centric infrastructure." ]
                        ]
                    , div [ class "coto" ]
                        [ div [ class "content" ]
                            [ text "The Old Way to deploy applications was to install the applications on a host using the operating system package manager. This had the disadvantage of entangling the applications’ executables, configuration, libraries, and lifecycles with each other and with the host OS. One could build immutable virtual-machine images in order to achieve predictable rollouts and rollbacks, but VMs are heavyweight and non-portable." ]
                        ]
                    , div [ class "coto" ]
                        [ div [ class "content" ]
                            [ text "The New Way is to deploy containers based on operating-system-level virtualization rather than hardware virtualization. These containers are isolated from each other and from the host: they have their own filesystems, they can’t see each others’ processes, and their computational resource usage can be bounded. They are easier to build than VMs, and because they are decoupled from the underlying infrastructure and from the host filesystem, they are portable across clouds and OS distributions." ]
                        ]
                    , div [ class "coto" ]
                        [ div [ class "content" ]
                            [ text "Because containers are small and fast, one application can be packed in each container image. This one-to-one application-to-image relationship unlocks the full benefits of containers. With containers, immutable container images can be created at build/release time rather than deployment time, since each application doesn’t need to be composed with the rest of the application stack, nor married to the production infrastructure environment. Generating container images at build/release time enables a consistent environment to be carried from development into production. Similarly, containers are vastly more transparent than VMs, which facilitates monitoring and management. This is especially true when the containers’ process lifecycles are managed by the infrastructure rather than hidden by a process supervisor inside the container. Finally, with a single application per container, managing the containers becomes tantamount to managing deployment of the application." ]
                        ]
                    ]
                ]
            ]
        , div [ id "column-traversal", class "connections-column" ]
            [ div [ class "coto" ]
                [ div [ class "content" ]
                    [ text "Elixir" ]
                ]
            ]
        ]


rootConnections : Model -> Html Msg
rootConnections model =
    connectionsDiv "root-connections" model.rootConnections model


traversalCoto : List Connection -> Coto -> Model -> Html Msg
traversalCoto connections coto model =
    div [ class "coto" ]
        [ markdown coto.content
        , connectionsDiv "sub-cotos" connections model
        ]
  

connectionsDiv : String -> List Connection -> Model -> Html Msg
connectionsDiv divClass connections model =
    Html.Keyed.node
        "div"
        [ class divClass ]
        (List.map 
            (\conn ->
                let
                    maybeCoto = Dict.get conn.end model.cotos
                in
                    ( conn.key
                    , case maybeCoto of
                        Nothing -> div [ class "coto missing" ] [ text "Missing" ]
                        Just coto -> cotoDiv coto
                    )
            ) 
            connections
        )
        
  
cotoDiv : Coto -> Html Msg
cotoDiv coto =
    div [ class "coto" ] [ markdown coto.content ]
    

markdown : String -> Html Msg
markdown content =
    div [ class "content" ]
        <| Markdown.customHtml 
            markdownOptions
            markdownElements
            content
