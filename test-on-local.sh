#!/bin/bash

if [ -n "$DOCKER_HOST" ]; then
  DOCKER_HOST_IP=$(echo $DOCKER_HOST | sed 's/^.*\/\/\(.*\):[0-9][0-9]*$/\1/g')
else
  DOCKER_HOST_IP="127.0.0.1"
fi

# Redis
echo
echo "# Running redis..."
REDIS_ID=$(docker run -d -p 16379:6379 redis:alpine)
export COTOAMI_REDIS_HOST=$DOCKER_HOST_IP
export COTOAMI_REDIS_PORT=16379

# PostgreSQL
echo
echo "# Running postgres..."
POSTGRES_ID=$(docker run -d -p 15432:5432 -e POSTGRES_PASSWORD=postgres postgres:alpine)
export COTOAMI_TEST_REPO_HOST=$DOCKER_HOST_IP
export COTOAMI_TEST_REPO_PORT=15432

# Neo4j
echo
echo "# Running neo4j..."
NEO4J_ID=$(docker run -d -p 17687:7687 neo4j:3.2.2)
export COTOAMI_NEO4J_HOST=$DOCKER_HOST_IP
export COTOAMI_NEO4J_PORT=17687

# Make sure to tear down containers
function tear_down_containers() {
  echo
  echo "# Tearing down containers..."
  docker stop $REDIS_ID && docker rm $REDIS_ID
  docker stop $POSTGRES_ID && docker rm $POSTGRES_ID
  docker stop $NEO4J_ID && docker rm $NEO4J_ID
}
trap tear_down_containers 0 1 2 3 15

# Run tests
echo
echo "# Running tests..."
export MIX_ENV="test"
mix do deps.get, deps.compile, compile, test
