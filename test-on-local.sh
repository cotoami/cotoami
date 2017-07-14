#!/bin/bash

source ./ci/setup-test.sh

# Make sure to tear down the backend containers
function tear_down_containers() {
  echo
  echo "# Tearing down containers..."
  docker stop $DOCKER_REDIS_ID && docker rm $DOCKER_REDIS_ID
  docker stop $DOCKER_POSTGRES_ID && docker rm $DOCKER_POSTGRES_ID
  docker stop $DOCKER_NEO4J_ID && docker rm $DOCKER_NEO4J_ID
}
trap tear_down_containers 0 1 2 3 15

# Run tests
echo
echo "# Running tests..."
export MIX_ENV="test"
if [[ $* == *-s* ]]; then
  echo "skip getting dependencies..."
  mix do compile, test
else
  mix do deps.get, deps.compile, compile, test
fi
