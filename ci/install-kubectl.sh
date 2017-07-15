#!/bin/bash

set -ex

apt-get -y -qq update
apt-get -y -qq install curl jq gettext

# awscli
pip install awscli --upgrade --user

# install kubectl
if [ ! -e ~/.kube ]; then
  mkdir -p ~/.kube;
fi
if [ ! -e ~/.kube/kubectl ]; then
  curl Ss -L https://storage.googleapis.com/kubernetes-release/release/v${KUBE_VERSION}/bin/linux/amd64/kubectl -o ~/.kube/kubectl
  chmod +x ~/.kube/kubectl
fi

aws s3 cp ${S3_KUBE_CONF} ~/.kube/config

~/.kube/kubectl version
