#!/bin/bash

export COMPOSE_PROJECT_NAME=cotoami
export COTOAMI_HOST=${COTOAMI_HOST:-localhost}

wget -q https://raw.githubusercontent.com/cotoami/cotoami/${BRANCH_OR_TAG:-master}/launch/docker-compose.yml -O docker-compose.yml

docker-compose up -d

echo
echo "Cotoami will be ready at http://$COTOAMI_HOST:4000"
echo "You can check sign-up/in mails at http://$COTOAMI_HOST:8080"
