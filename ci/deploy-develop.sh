#!/bin/bash

~/.kube/kubectl config use-context $KUBE_CONTEXT

BUILD_TIMESTAMP="$(date +"%Y.%m.%d.%H.%M")"
PATCH='{"spec":{"template":{"spec":{"containers":[{"name":"cotoami","env":[{"name":"CHANGE_THIS_TO_FORCE_UPDATE","value":"'"${BUILD_TIMESTAMP}"'"}]}]}}}}'

for dep in $DEPLOYMENTS_FOR_DEV
do
  echo "Updating [$dep] ..."
  ~/.kube/kubectl --namespace='prod-cotoami' patch deployment $dep -p $PATCH
done
