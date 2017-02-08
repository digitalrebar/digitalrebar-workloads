#!/bin/bash

# Make sure the unzip and git are installed
install unzip git

# Move to temp directory
cd /tmp
# Get and install deis cli
curl -sSL http://deis.io/deis-cli/install-v2.sh | bash
mv deis /usr/local/bin/deis
cd -

# Get deis charts
if ! helm repo list | grep deis >/dev/null 2>/dev/null ; then
    helm repo add deis https://charts.deis.com/workflow
fi

helm install deis/workflow --namespace deis

# Wait for deis to finish starting
while [[ $(kubectl --namespace=deis get pods --no-headers | grep -v Running | wc -l) != 0 ]] ; do
    sleep 5
done

