#!/bin/bash

docker run --net=host  -i -t \
  -v `pwd`:/build \
  -v /etc/localtime:/etc/localtime:ro \
  --env-file ~/test-env-vars \
  elixir /bin/sh -c 'cd /build && MIX_ENV="test" mix do deps.get, deps.compile, compile, test'
