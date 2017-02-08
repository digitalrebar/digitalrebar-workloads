#!/bin/bash

# Make sure the unzip and git are installed
install unzip git

# Get and install helm 
curl https://raw.githubusercontent.com/kubernetes/helm/master/scripts/get | sed 's/sudo//' | bash

# Start helm/tiller
helm init

# Wait for tiller to start
while [[ $(kubectl --namespace=kube-system get pods --no-headers | grep -v Running | grep tiller | wc -l) != 0 ]] ; do
    sleep 5
done

