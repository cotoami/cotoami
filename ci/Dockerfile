FROM ubuntu:trusty

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update -q
RUN apt-get -y install language-pack-ja openssl libssl-dev ncurses-dev curl git

# Locale
RUN update-locale LANG=ja_JP.UTF-8
ENV LANG ja_JP.UTF-8
ENV LANGUAGE ja_JP:ja
ENV LC_ALL ja_JP.UTF-8

# Node.js
RUN apt-get -y install rlwrap && \
    curl -o /tmp/nodejs.deb https://deb.nodesource.com/node_5.x/pool/main/n/nodejs/nodejs_5.5.0-1nodesource1~trusty1_amd64.deb && \
    dpkg -i /tmp/nodejs.deb && \
    rm -rf /tmp/nodejs.deb

# Erlang and Elixir
RUN curl -o /tmp/erlang.deb http://packages.erlang-solutions.com/erlang-solutions_1.0_all.deb && \
    dpkg -i /tmp/erlang.deb && \
    rm -rf /tmp/erlang.deb && \
    apt-get update -q
    
RUN apt-cache show esl-erlang && apt-cache show elixir
    
RUN apt-get install -y esl-erlang=1:19.0.2 && \
    apt-get install -y elixir=1.3.2-1 && \
    apt-get clean -y

RUN mix local.hex --force && mix local.rebar --force

# PostgreSQL
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys B97B0AFCAA1A47F044F244A07FCC7D46ACCC4CF8
RUN echo "deb http://apt.postgresql.org/pub/repos/apt/ precise-pgdg main" > /etc/apt/sources.list.d/pgdg.list
RUN apt-get update && apt-get -y -q install python-software-properties software-properties-common \
    && apt-get -y -q install postgresql-9.3 postgresql-client-9.3 postgresql-contrib-9.3

# Alter postgres user for test
USER postgres
RUN /etc/init.d/postgresql start \
    && psql --command "ALTER USER postgres WITH SUPERUSER PASSWORD 'postgres';"

USER root
