#!/bin/bash


SVC_NAME=monitoring
NAMESPACE=monitoring

if [ ! -d k8s ] ; then
    install git
    git clone https://github.com/gregbkr/kubernetes-kargo-logging-monitoring.git k8s
fi

cd k8s

if [ -e monitoring/grafana-import-dashboards-job.yaml ] ; then
  mv monitoring/grafana-import-dashboards-job.yaml monitoring/grafana-import-dashboards-job.yaml.not.now
fi
kubectl apply -f $SVC_NAME

while kubectl get -n $NAMESPACE pods --no-headers | grep -v Running ; do
  echo "Waiting for $SVC_NAME to start"
  sleep 5
done

