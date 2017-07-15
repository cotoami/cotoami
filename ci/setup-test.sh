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
export COTOAMI_REDIS_HOST=$DOCKER_HOST_IP
export COTOAMI_REDIS_PORT=16379
export DOCKER_REDIS_ID=$(docker run -d -p $COTOAMI_REDIS_PORT:6379 redis:alpine)


# PostgreSQL
if [[ $* == *--circleci* ]]; then
  echo
  echo "# Use CircleCI's postgres"
else
  echo
  echo "# Running postgres..."
  export COTOAMI_TEST_REPO_HOST=$DOCKER_HOST_IP
  export COTOAMI_TEST_REPO_PORT=15432
  export DOCKER_POSTGRES_ID=$(docker run -d \
    -p $COTOAMI_TEST_REPO_PORT:5432 \
    -e POSTGRES_PASSWORD=postgres \
    postgres:alpine)
  echo "  waiting for postgres to be launched..."
  while ! nc -z $DOCKER_HOST_IP $COTOAMI_TEST_REPO_PORT; do
    sleep 1s
  done
fi

# Neo4j
echo
echo "# Running neo4j..."
NEO4J_VERSION=3.2.2
export COTOAMI_NEO4J_HOST=$DOCKER_HOST_IP
export COTOAMI_NEO4J_PORT=17687
if [[ $* == *--circleci* ]]; then
  #
  # For some reason, neo4j:3.2.2 won't run on circleci with the default settings.
  # The following errors occurred during starting up:
  #
  # 1) Error occurred during initialization of VM
  #    The flag -XX:+UseG1GC can not be combined with -XX:ParallelGCThreads=0
  #
  # Fixed this by setting "-XX:ParallelGCThreads=2" and then,
  #
  # 2) org.neo4j.graphdb.config.InvalidSettingException:
  #    Bad value '0' for setting 'dbms.threads.worker_count': minimum allowed value is: 1
  #    at org.neo4j.kernel.configuration.Settings$DefaultSetting.apply(Settings.java:1304)
  #
  # This seems to be caused by the default /var/lib/neo4j/conf/neo4j.conf
  # in which 'dbms.threads.worker_count' is commented out. Setting this
  # by NEO4J_xxx env var or a /conf volume won't work. Instead, directly
  # mounting on the default conf file solves the error.
  #
  # ref. http://neo4j.com/docs/operations-manual/current/installation/docker/
  # ref. https://github.com/neo4j/docker-neo4j/blob/master/src/3.2/docker-entrypoint.sh
  #
  NEO4J_CONF_DIR=$(cd ${BASH_SOURCE%/*}/neo4j; pwd)
  export DOCKER_NEO4J_ID=$(docker run -d \
    -p $COTOAMI_NEO4J_PORT:7687 \
    -e NEO4J_AUTH=none \
    -v $NEO4J_CONF_DIR:/var/lib/neo4j/conf \
    neo4j:$NEO4J_VERSION)
else
  export DOCKER_NEO4J_ID=$(docker run -d \
    -p $COTOAMI_NEO4J_PORT:7687 \
    -e NEO4J_AUTH=none \
    neo4j:$NEO4J_VERSION)
fi
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
