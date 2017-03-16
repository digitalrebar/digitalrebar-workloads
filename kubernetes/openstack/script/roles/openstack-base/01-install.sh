#!/bin/bash

case $OS_FAMILY in
  rhel) yum -y install ceph --skip-broken;;
  debian) apt-get install -y ceph-common ceph-fs-common;;
  *) echo "No idea how to install packages on $OS_NAME"; exit 1;;
esac

mkdir -p /var/lib/openstack-helm/ceph

# This seems to be a hack for an openstack-helm bug
mkdir -p /var/lib/nova/instances

