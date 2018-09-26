FROM cotoami/cotoami

RUN locale-gen uk_UA.UTF-8 
ENV LANG uk_UA.UTF-8  
ENV LANGUAGE uk_UA:uk  
ENV LC_ALL uk_UA.UTF-8
     
ENV APP_PORT 4000

EXPOSE ${APP_PORT}

RUN mix local.hex --force

WORKDIR /app
ADD . /app

RUN mix deps.get

CMD ["/bin/bash", "-c", "PORT=${APP_PORT} mix phx.server"]
