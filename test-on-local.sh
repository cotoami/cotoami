#!/bin/bash

if [ -n "$DOCKER_HOST" ]; then
  DOCKER_HOST_IP=$(echo $DOCKER_HOST | sed 's/^.*\/\/\(.*\):[0-9][0-9]*$/\1/g')
else
  DOCKER_HOST_IP="127.0.0.1"
fi

# Redis
echo
echo "# Running redis..."
export COTOAMI_REDIS_HOST=$DOCKER_HOST_IP
export COTOAMI_REDIS_PORT=16379
export DOCKER_REDIS_ID=$(docker run -d -p $COTOAMI_REDIS_PORT:6379 redis:alpine)

# PostgreSQL
echo
echo "# Running postgres..."
export COTOAMI_TEST_REPO_HOST=$DOCKER_HOST_IP
export COTOAMI_TEST_REPO_PORT=15432
export DOCKER_POSTGRES_ID=$(docker run -d \
  -p $COTOAMI_TEST_REPO_PORT:5432 \
  -e POSTGRES_PASSWORD=postgres \
  postgres:9.5-alpine)
echo "  waiting for postgres to be launched..."
while ! nc -z $DOCKER_HOST_IP $COTOAMI_TEST_REPO_PORT; do
  sleep 1s
done

# Neo4j
echo
echo "# Running neo4j..."
NEO4J_VERSION=3.2.2
export COTOAMI_NEO4J_HOST=$DOCKER_HOST_IP
export COTOAMI_NEO4J_PORT=17687
export DOCKER_NEO4J_ID=$(docker run -d \
  -p $COTOAMI_NEO4J_PORT:7687 \
  -e NEO4J_AUTH=none \
  neo4j:$NEO4J_VERSION)
echo "  waiting for neo4j to be launched..."
while ! nc -z $DOCKER_HOST_IP $COTOAMI_NEO4J_PORT; do
  sleep 1s
done

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
