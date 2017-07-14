#!/bin/bash

set -e

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
if [[ $* == *--circleci* ]]; then
  echo
  echo "# Use CircleCI's postgres"
else
  echo
  echo "# Running postgres..."
  export DOCKER_POSTGRES_ID=$(docker run -d -p 15432:5432 -e POSTGRES_PASSWORD=postgres postgres:alpine)
  export COTOAMI_TEST_REPO_HOST=$DOCKER_HOST_IP
  export COTOAMI_TEST_REPO_PORT=15432
  echo "  waiting for postgres to be launched..."
  while ! nc -z $DOCKER_HOST_IP $COTOAMI_TEST_REPO_PORT; do
    sleep 1s
  done
fi

# Neo4j
echo
echo "# Running neo4j..."
export DOCKER_NEO4J_ID=$(docker run -d -p 17687:7687 -e NEO4J_AUTH=none -e NEO4J_dbms_jvm_additional="-XX:ParallelGCThreads=2" --ulimit=nofile=40000:40000 neo4j:3.2.2)
export COTOAMI_NEO4J_HOST=$DOCKER_HOST_IP
export COTOAMI_NEO4J_PORT=17687
echo "  waiting for neo4j to be launched..."
while ! nc -z $DOCKER_HOST_IP $COTOAMI_NEO4J_PORT; do
  if [[ $* == *--circleci* ]]; then
    sleep 10s
    echo
    echo "neo4j log {"
    docker logs $DOCKER_NEO4J_ID
    echo "}"
  else
    sleep 1s
  fi
done
