#!/bin/bash

install uuid-runtime make
curl -L https://github.com/gliderlabs/sigil/releases/download/v0.4.0/sigil_0.4.0_Linux_x86_64.tgz | tar -zxC /usr/local/bin

cd /root
rm -rf openstack-helm
git clone https://github.com/galthaus/openstack-helm.git

kubectl get nodes --no-headers | grep -v Schedul | awk '{ print $1 }' | while read node
do
    kubectl label node $node openstack-control-plane=enabled --overwrite=true
    kubectl label node $node ceph-storage=enabled --overwrite=true
    kubectl label node $node openvswitch=enabled --overwrite=true
    kubectl label node $node openstack-compute-node=enabled --overwrite=true
done

DNSIP=$(kubectl get svc -n kube-system dnsmasq --no-headers | awk '{ print $2 }')
PODIPS=$(read_attribute "kube_pod_subnet")

export osd_cluster_network=$PODIPS
export osd_public_network=$PODIPS

cd openstack-helm
cd common/utils/secret-generator
./generate_secrets.sh all `./generate_secrets.sh fsid`
cd ../../..

if ! ps auxwww | grep "helm serve" | grep -qv grep ; then
    nohup helm serve . 2&>/dev/null &>/dev/null &
    sleep 10
fi

helm repo add local http://localhost:8879/charts

make

# Example with osd disks
#helm install \
#  --set network.public=$osd_public_network,resources.osd.requests.cpu="100m",resources.mon.requests.cpu="100m",osd.daemon="osd",osd.zap="1" \
#  --name=ceph local/ceph --namespace=ceph

helm install \
  --set network.public=$osd_public_network,resources.osd.requests.cpu="100m",resources.mon.requests.cpu="100m" \
  --name=ceph local/ceph --namespace=ceph

helm install --name=bootstrap-ceph local/bootstrap --namespace=ceph
helm install --name=bootstrap-openstack local/bootstrap --namespace=openstack

while ! kubectl exec -n ceph -it ceph-mon-0 ceph status | grep health | grep HEALTH_OK
do
    echo "Waiting for Ceph to come up"
    sleep 30
done

# Create ceph volumes pool for cinder
kubectl exec -n ceph -it ceph-mon-0 ceph osd pool create volumes 128
kubectl exec -n ceph -it ceph-mon-0 ceph osd pool create images 128
# Optionally, ceph can provide nova with a vm pool
# kubectl exec -n ceph -it ceph-mon-0 ceph osd pool create vms 128

helm install --name mariadb local/mariadb --namespace=openstack
helm install --name=memcached local/memcached --namespace=openstack
helm install --name=rabbitmq local/rabbitmq --namespace=openstack
helm install --name=keystone local/keystone --namespace=openstack
helm install --name=cinder local/cinder --namespace=openstack
helm install --name=glance local/glance --namespace=openstack
helm install --name=heat local/heat --namespace=openstack
helm install --set network.dns.servers={$DNSIP} --name=nova local/nova --namespace=openstack
helm install --set network.dns.servers={$DNSIP} --name=neutron local/neutron --namespace=openstack
helm install --name=horizon local/horizon --namespace=openstack

