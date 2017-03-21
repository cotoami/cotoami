# From a local image 'elixir' built in CircleCI
FROM elixir

ENV APP_PORT 80

EXPOSE ${APP_PORT}

ADD . /app
WORKDIR /app

CMD ["/bin/bash", "-c", "PORT=${APP_PORT} MIX_ENV=prod mix phoenix.server"] 
