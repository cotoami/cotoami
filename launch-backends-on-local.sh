#!/bin/bash

#
# Run backend services as docker containers
#

if [ -n "$DOCKER_HOST" ]; then
  DOCKER_HOST_IP=$(echo $DOCKER_HOST | sed 's/^.*\/\/\(.*\):[0-9][0-9]*$/\1/g')
else
  DOCKER_HOST_IP="127.0.0.1"
fi

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

# Mail server
echo
echo "# Running maildev..."
docker run -d -p 25:25 -p 8080:80 djfarrelly/maildev:latest
export COTOAMI_SMTP_SERVER=$DOCKER_HOST_IP
export COTOAMI_SMTP_PORT=25
echo
echo "You can check sign-up/in mails at http://$DOCKER_HOST_IP:8080"

# Mail sender
export COTOAMI_EMAIL_FROM="no-reply@cotoa.me"
