#!/bin/bash

set -ex

apt-get -y -qq update
apt-get -y -qq install sudo wget jq gettext python3.4-dev

# awscli
curl -O https://bootstrap.pypa.io/get-pip.py
python3.4 get-pip.py --user
pip install awscli --upgrade --user

# install kubectl
if [ ! -e ~/.kube ]; then
    mkdir -p ~/.kube;
fi
if [ ! -e ~/.kube/kubectl ]; then
    wget https://storage.googleapis.com/kubernetes-release/release/v${KUBE_VERSION}/bin/linux/amd64/kubectl -O ~/.kube/kubectl
    chmod +x ~/.kube/kubectl
fi

aws s3 cp ${S3_KUBE_CONF} ~/.kube/config

~/.kube/kubectl version
