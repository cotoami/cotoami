#!/bin/bash

set -ex

mkdir -p ~/docker

function cache_image() {
  if [[ ! -e ~/docker/$2.tar ]]; then
    docker save $1 > ~/docker/$2.tar
  fi
}

docker images

cache_image "redis:alpine" "redis"
cache_image "neo4j:3.2.2" "neo4j"

ls -l ~/docker/
