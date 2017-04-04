# Cotoami

[![CircleCI](https://circleci.com/gh/cotoami/cotoami.svg?style=svg)](https://circleci.com/gh/cotoami/cotoami)

Cotoami (言編み・言網) is a platform where people can weave a large network of knowledge from tiny ideas.

Cotoami is an open source project, sponsored by [UNIVA Paycast](https://www.univapay.com) under the Apache 2.0 Licence.

## Concept

Cotoami's concept of knowledge generation:

![](docs/images/cotoami-concept.png)

* **Coto**: Post. A unit of information in Cotoami.
* **Cotonoma**: Chatroom-like unit which has a timeline and coto-connections. Nestable.

## Roadmap

* Cotoami Roadmap - https://github.com/cotoami/cotoami/issues/2

## Requirements

* Node.js 5.0.0 or greater
* Elixir 1.3.x
* Phoenix 1.2.x
* Elm 0.18.x

## Configuration 

Environment variables: 

* App URL - configuration for generating URLs throughout the app
    * `COTOAMI_URL_SCHEME` - URL scheme of the app
    * `COTOAMI_URL_HOST` - host name of the app
    * `COTOAMI_URL_PORT` - port number of the app
* Redis
    * `COTOAMI_REDIS_HOST` - host name of the Redis server
* PostgreSQL
    * `COTOAMI_REPO_HOST` - host name of the PostgreSQL server
    * `COTOAMI_REPO_DATABASE` - database name
    * `COTOAMI_REPO_USER` - user name
    * `COTOAMI_REPO_PASSWORD` - password
* Mail
    * `COTOAMI_EMAIL_FROM` - email address for "from"
    * `COTOAMI_SMTP_SERVER` - host name of the SMTP server
    * `COTOAMI_SMTP_PORT` - port number of the SMTP server
    * `COTOAMI_SMTP_USER` - SMTP user name
    * `COTOAMI_SMTP_PASSWORD` - SMTP password

## How to run app locally

1. Install dependencies with `mix deps.get`
2. Create and migrate your database with `mix ecto.create && mix ecto.migrate`
3. Install Node.js dependencies with `npm install`
4. Start Phoenix endpoint with `mix phoenix.server`

Now you can visit `localhost:4000` from your browser.
