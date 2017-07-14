#!/bin/bash

set -ex

function load_image() {
  if [[ -e ~/docker/$1.tar ]]; then
    docker load -i ~/docker/$1.tar;
  fi
}

load_image "redis"
load_image "postgres"
load_image "neo4j"
