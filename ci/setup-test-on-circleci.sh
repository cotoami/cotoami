#!/bin/bash

source "${BASH_SOURCE%/*}/setup-test.sh" --circleci

# write env vars to file
cat <<EOT >> ~/test-env-vars
COTOAMI_REDIS_HOST=${COTOAMI_REDIS_HOST}
COTOAMI_REDIS_PORT=${COTOAMI_REDIS_PORT}
COTOAMI_NEO4J_HOST=${COTOAMI_NEO4J_HOST}
COTOAMI_NEO4J_PORT=${COTOAMI_NEO4J_PORT}
EOT
