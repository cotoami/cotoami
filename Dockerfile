# From a local image 'elixir' built in CircleCI
FROM elixir

ENV APP_PORT 8080

EXPOSE ${APP_PORT}

ADD . /app
WORKDIR /app

RUN mix deps.get --only prod
RUN MIX_ENV=prod mix compile

RUN npm install
RUN node_modules/brunch/bin/brunch build --production
RUN MIX_ENV=prod mix phoenix.digest

CMD ["/bin/bash", "-c", "PORT=${APP_PORT} MIX_ENV=prod mix phoenix.server"] 
