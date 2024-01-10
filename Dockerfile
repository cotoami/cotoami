FROM cotoami/cotoami-elixir:1.10-focal

ENV APP_PORT 4000

EXPOSE ${APP_PORT}

ADD . /app
WORKDIR /app

CMD ["/bin/bash", "-c", "PORT=${APP_PORT} MIX_ENV=prod mix phx.server"]
