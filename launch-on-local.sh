#!/bin/bash

if [ -n "$DOCKER_HOST" ]; then
  DOCKER_HOST_IP=$(echo $DOCKER_HOST | sed 's/^.*\/\/\(.*\):[0-9][0-9]*$/\1/g')
else
  DOCKER_HOST_IP="127.0.0.1"
fi

#
# Run backend services as docker containers
#

# Redis
echo
echo "# Running redis..."
docker run -d -p 6379:6379 redis:alpine
export COTOAMI_REDIS_HOST=$DOCKER_HOST_IP

# PostgreSQL
echo
echo "# Running postgres..."
docker run -d -p 5432:5432 -e POSTGRES_PASSWORD=postgres -e POSTGRES_DB=cotoami_dev postgres:alpine
export COTOAMI_DEV_REPO_HOST=$DOCKER_HOST_IP

#
# Get dependencies
#

echo
echo "# Getting dependencies..."
mix deps.get
npm install

#
# Launch app
#

echo
echo "# Launching cotoami..."
mix phoenix.server
