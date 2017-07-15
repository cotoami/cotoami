FROM cotoami/cotoami-elixir:1.4.5

ENV APP_PORT 4000

EXPOSE ${APP_PORT}

ADD . /app
WORKDIR /app

CMD ["/bin/bash", "-c", "PORT=${APP_PORT} MIX_ENV=prod mix phoenix.server"]
