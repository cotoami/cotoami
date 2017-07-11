#!/bin/bash

# Get dependencies
echo
echo "# Getting dependencies..."
mix do deps.get, deps.compile
npm install

# Launch backend services
source ./launch-backends-on-local.sh

# Launch app
echo
echo "# Launching cotoami..."
mix phoenix.server
