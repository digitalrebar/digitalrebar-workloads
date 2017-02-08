#!/bin/bash


SVC_NAME=monitoring2
NAMESPACE=monitoring2

if [ ! -d k8s ] ; then
    install git
    git clone https://github.com/gregbkr/kubernetes-kargo-logging-monitoring.git k8s
fi

cd k8s

kubectl apply -f $SVC_NAME

while kubectl get -n $NAMESPACE pods --no-headers | grep -v Running ; do
  echo "Waiting for $SVC_NAME to start"
  sleep 5
done

