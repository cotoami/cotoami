#!/bin/bash

source "${BASH_SOURCE%/*}/setup-test.sh"

docker run --net=host -v `pwd`:/build -v /etc/localtime:/etc/localtime:ro -i -t \
  -e COTOAMI_REDIS_HOST \
  -e COTOAMI_REDIS_PORT \
  -e COTOAMI_TEST_REPO_HOST \
  -e COTOAMI_TEST_REPO_PORT \
  -e COTOAMI_NEO4J_HOST \
  -e COTOAMI_NEO4J_PORT \
  elixir /bin/sh -c 'cd /build && MIX_ENV="test" mix do deps.get, deps.compile, compile, test'
