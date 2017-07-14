#!/bin/bash

docker run --net=host -v `pwd`:/build -v /etc/localtime:/etc/localtime:ro -i -t \
  --env-file ~/test-env-vars
  elixir /bin/sh -c 'cd /build && MIX_ENV="test" mix do deps.get, deps.compile, compile, test'
