#!/bin/bash

set -ex

DOCKERIZE_VERSION="v0.3.0"
DOCKERIZE_DOWNLOAD_URL=https://github.com/jwilder/dockerize/releases/download/$DOCKERIZE_VERSION/dockerize-linux-amd64-$DOCKERIZE_VERSION.tar.gz

curl -Ss -L $DOCKERIZE_DOWNLOAD_URL -o dockerize.tar.gz
sudo tar -xzvf dockerize.tar.gz -C /usr/local/bin
rm dockerize.tar.gz
