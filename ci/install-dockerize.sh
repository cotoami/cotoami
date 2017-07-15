#!/bin/bash

DOCKERIZE_VERSION="v0.3.0"
DOCKERIZE_DOWNLOAD_URL=https://github.com/jwilder/dockerize/releases/download/$DOCKERIZE_VERSION/dockerize-linux-amd64-$DOCKERIZE_VERSION.tar.gz

curl DOCKERIZE_DOWNLOAD_URL -o dockerize.tar.gz
sudo tar -C /usr/local/bin -xzvf dockerize.tar.gz
rm dockerize.tar.gz
