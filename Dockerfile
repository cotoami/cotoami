# From a local image 'elixir' built in CircleCI
FROM elixir

ENV APP_PORT 80

EXPOSE ${APP_PORT}

ADD . /app
WORKDIR /app

# Compile elixir code
RUN mix deps.get --only prod
RUN MIX_ENV=prod mix compile

# Assets
RUN npm install
RUN cd elm && elm-install
RUN node_modules/brunch/bin/brunch build --production
RUN MIX_ENV=prod mix phoenix.digest

CMD ["/bin/bash", "-c", "PORT=${APP_PORT} MIX_ENV=prod mix phoenix.server"] 
