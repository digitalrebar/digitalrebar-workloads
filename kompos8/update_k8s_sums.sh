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

echo "Downloading six components for $K8S_VERSION (SLOW way, no compression)"
curl https://storage.googleapis.com/kubernetes-release/release/${K8S_VERSION}/bin/linux/amd64/kube-apiserver -o kube-apiserver
curl https://storage.googleapis.com/kubernetes-release/release/${K8S_VERSION}/bin/linux/amd64/kkube-controller-manager -o kube-controller-manager
curl https://storage.googleapis.com/kubernetes-release/release/${K8S_VERSION}/bin/linux/amd64/kube-scheduler -o kube-scheduler
curl https://storage.googleapis.com/kubernetes-release/release/${K8S_VERSION}/bin/linux/amd64/kubelet -o kubelet
curl https://storage.googleapis.com/kubernetes-release/release/${K8S_VERSION}/bin/linux/amd64/kube-proxy -o kube-proxy
curl https://storage.googleapis.com/kubernetes-release/release/${K8S_VERSION}/bin/linux/amd64/kubectl -o kubectl

echo "Compute Checksum"
API_SERVER=$(shasum -a 256 kube-apiserver | awk '{ print $1 }')
CONTROLLER=$(shasum -a 256 kube-controller-manager | awk '{ print $1 }')
SCHEDULER=$(shasum -a 256 kube-scheduler | awk '{ print $1 }')
KUBELET=$(shasum -a 256 kubelet | awk '{ print $1 }')
PROXY=$(shasum -a 256 kube-proxy | awk '{ print $1 }')
KUBECTL=$(shasum -a 256 kubectl | awk '{ print $1 }')

cd $CODE_DIR
rm -rf /tmp/$$.dl

echo "Add checksums to group_vars/all.yml"
echo "    ${K8S_VERSION}:" >> group_vars/all.yml
echo "      kube-apiserver: \"sha256:$API_SERVER\"" >> group_vars/all.yml
echo "      kube-controller-manager: \"sha256:$CONTROLLER\"" >> group_vars/all.yml
echo "      kube-scheduler: \"sha256:$SCHEDULER\"" >> group_vars/all.yml
echo "      kubelet: \"sha256:$KUBELET\"" >> group_vars/all.yml
echo "      kube-proxy: \"sha256:$PROXY\"" >> group_vars/all.yml
echo "      kubectl: \"sha256:$KUBECTL\"" >> group_vars/all.yml

