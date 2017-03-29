module Components.Connections.View exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Components.Connections.Model exposing (..)
import Components.Connections.Messages exposing (..)


view : Model -> Html Msg
view model =
    div [ id "connections" ] 
        [ div [ id "column-roots", class "connections-column" ]
            [ div [ class "coto" ]
                [ div [ class "content" ]
                    [ text "Is is possible to attach additional security groups to the rules for the node security group? Our use case is that we want to deploy Kubernetes into an existing VPC. The Kubernetes VPC is peered with another VPC that holds things like RDS instances and long-lived EC2 sysstems and want the Kubernetes nodes to be able to communicate with these systems by basically creating an ALLOW ALL set of ingress and egress rules." ]
                ]
            , div [ class "coto" ]
                [ div [ class "content" ]
                    [ text "Kubernetes" ]
                ]
            , div [ class "coto" ]
                [ div [ class "content" ]
                    [ text "ODLEは有機化合物を用いた発光素子で、液晶（LCD）などに比べ薄型で軽量、かつ低消費電力、高速応答、高コントラストなどの特徴があります。サムスンディスプレイでは、アクティブマトリクスという駆動方式を採用したAMOLED(Active Matrix Organic Light Emitting Diode)を主力にしています。AMOLEDは、Apple Watchやサムスンギャラクシーシリーズに搭載されています。変形が用意であるため、スマホ表示面のエッジを曲げることなども可能です。" ]
                ]
            ]
        , div [ id "column-traversal", class "connections-column" ]
            [ div [ class "coto" ]
                [ div [ class "content" ]
                    [ text "Kubernetes" ]
                ]
            ]
        , div [ id "column-traversal", class "connections-column" ]
            [ div [ class "coto" ]
                [ div [ class "content" ]
                    [ text "Elixir" ]
                ]
            ]
        ]
