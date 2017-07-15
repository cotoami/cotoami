#!/bin/bash

DOCKERIZE_VERSION="v0.3.0"

wget https://github.com/jwilder/dockerize/releases/download/$DOCKERIZE_VERSION/dockerize-linux-amd64-$DOCKERIZE_VERSION.tar.gz
sudo tar -C /usr/local/bin -xzvf dockerize-linux-amd64-$DOCKERIZE_VERSION.tar.gz
rm dockerize-linux-amd64-$DOCKERIZE_VERSION.tar.gz
