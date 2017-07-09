#!/bin/bash

if [ -n "$DOCKER_HOST" ]; then
  DOCKER_HOST_IP=$(echo $DOCKER_HOST | sed 's/^.*\/\/\(.*\):[0-9][0-9]*$/\1/g')
else
  DOCKER_HOST_IP="127.0.0.1"
fi

# PostgreSQL
echo
echo "# Running postgres..."
POSTGRES_ID=$(docker run -d -p 15432:5432 -e POSTGRES_PASSWORD=postgres postgres:alpine)
export COTOAMI_TEST_REPO_HOST=$DOCKER_HOST_IP
export COTOAMI_TEST_REPO_PORT=15432

# Run tests
echo
echo "# Running tests..."
export MIX_ENV="test"
mix do deps.get, deps.compile, compile, test

# Stop and remove containers
echo
echo "# Tearing down containers..."
docker stop $POSTGRES_ID && docker rm $POSTGRES_ID
