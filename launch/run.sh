#!/bin/bash

if [ -n "$DOCKER_HOST" ]; then
  DOCKER_HOST_IP=$(echo $DOCKER_HOST | sed 's/^.*\/\/\(.*\):[0-9][0-9]*$/\1/g')
elif [ -x "$(command -v docker-machine)" ]; then
  DOCKER_HOST_IP=$(docker-machine ip default)
else
  DOCKER_HOST_IP="127.0.0.1"
fi

export COMPOSE_PROJECT_NAME=cotoami
export COTOAMI_VERSION="v0.22.0"
export COTOAMI_HOST=$DOCKER_HOST_IP

wget -q https://raw.githubusercontent.com/cotoami/cotoami/$COTOAMI_VERSION/launch/docker-compose.yml -O docker-compose.yml

docker-compose up -d

echo
echo "Cotoami will be ready at http://$DOCKER_HOST_IP:4000"
echo "You can check sign-up/in mails at http://$DOCKER_HOST_IP:8080"
