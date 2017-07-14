#!/bin/bash

if [ -n "$DOCKER_HOST" ]; then
  DOCKER_HOST_IP=$(echo $DOCKER_HOST | sed 's/^.*\/\/\(.*\):[0-9][0-9]*$/\1/g')
else
  DOCKER_HOST_IP="127.0.0.1"
fi

# Redis
echo
echo "# Running redis..."
export DOCKER_REDIS_ID=$(docker run -d -p 16379:6379 redis:alpine)
export COTOAMI_REDIS_HOST=$DOCKER_HOST_IP
export COTOAMI_REDIS_PORT=16379

# PostgreSQL
echo
echo "# Running postgres..."
export DOCKER_POSTGRES_ID=$(docker run -d -p 15432:5432 -e POSTGRES_PASSWORD=postgres postgres:alpine)
export COTOAMI_TEST_REPO_HOST=$DOCKER_HOST_IP
export COTOAMI_TEST_REPO_PORT=15432
while ! nc -z $DOCKER_HOST_IP $COTOAMI_TEST_REPO_PORT; do
  sleep 0.1
done

# Neo4j
echo
echo "# Running neo4j..."
export DOCKER_NEO4J_ID=$(docker run -d -p 17687:7687 -e NEO4J_AUTH=none neo4j:3.2.2)
export COTOAMI_NEO4J_HOST=$DOCKER_HOST_IP
export COTOAMI_NEO4J_PORT=17687
while ! nc -z $DOCKER_HOST_IP $COTOAMI_NEO4J_PORT; do
  sleep 0.1
done
