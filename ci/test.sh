#!/bin/bash

export MIX_ENV="test"
mix do deps.get, deps.compile, compile, test
