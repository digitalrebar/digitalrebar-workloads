#!/bin/bash

if [[ $1 == "" ]] ; then
	echo "Specify a version to download. e.g. v1.3.5"
        exit -1
fi

K8S_VERSION=$1
FILE=$2

mkdir /tmp/$$.dl

CODE_DIR=`pwd`
cd /tmp/$$.dl

if [[ $FILE == "" ]] ; then
  echo "Downloading $K8S_VERSION"
  curl https://storage.googleapis.com/kubernetes-release/release/${K8S_VERSION}/kubernetes.tar.gz -o kubernetes.tgz
else
  echo "Copying $FILE"
  cp $2 kubernetes.tgz
fi

tar -xf kubernetes.tgz
cd kubernetes/server
tar -xf kubernetes-server-linux-amd64.tar.gz 
cd kubernetes/server/bin

API_SERVER=$(shasum -a 256 kube-apiserver | awk '{ print $1 }')
CONTROLLER=$(shasum -a 256 kube-controller-manager | awk '{ print $1 }')
SCHEDULER=$(shasum -a 256 kube-scheduler | awk '{ print $1 }')
KUBELET=$(shasum -a 256 kubelet | awk '{ print $1 }')
PROXY=$(shasum -a 256 kube-proxy | awk '{ print $1 }')
KUBECTL=$(shasum -a 256 kubectl | awk '{ print $1 }')

cd $CODE_DIR
rm -rf /tmp/$$.dl

echo "    ${K8S_VERSION}:" >> group_vars/all.yml
echo "      kube-apiserver: \"sha256:$API_SERVER\"" >> group_vars/all.yml
echo "      kube-controller-manager: \"sha256:$CONTROLLER\"" >> group_vars/all.yml
echo "      kube-scheduler: \"sha256:$SCHEDULER\"" >> group_vars/all.yml
echo "      kubelet: \"sha256:$KUBELET\"" >> group_vars/all.yml
echo "      kube-proxy: \"sha256:$PROXY\"" >> group_vars/all.yml
echo "      kubectl: \"sha256:$KUBECTL\"" >> group_vars/all.yml

