#!/bin/bash

set -x

export OS_PROJECT_DOMAIN_ID=default
export OS_USER_DOMAIN_ID=default
export OS_PROJECT_NAME=admin
export OS_TENANT_NAME=admin
export OS_USERNAME=admin
export OS_PASSWORD=password
export OS_AUTH_URL=http://keystone-api.openstack:35357/v3
export OS_IDENTITY_API_VERSION=3
export OS_REGION_NAME=RegionOne
export OS_INSECURE=1

apt-get install -y python-glanceclient
apt-get install -y python-openstackclient
apt-get install -y python-novaclient
apt-get install -y python-neutronclient

echo "Creating ubuntu xenial glance image"
curl https://cloud-images.ubuntu.com/xenial/current/xenial-server-cloudimg-amd64-disk1.img -o /root/xenial-server-cloudimg-amd64-disk1.img

glance image-create --name "Ubuntu Xenial" --disk-format qcow2 --container-format bare --file /root/xenial-server-cloudimg-amd64-disk1.img --visibility public --progress

# no flavors in nova
echo "Creating basic openstack flavor"
openstack flavor create --public m1.normal --id auto --ram 1024 --disk 60 --vcpus 1 --rxtx-factor 1

# allow port 22 and icmp
echo "Updating default security groups to allow icmp and ssh"
nova secgroup-add-rule default tcp 22 22 0.0.0.0/0
nova secgroup-add-rule default icmp -1 -1 0.0.0.0/0

# create network
echo "Creating neutron networks"
neutron net-create flat-network --provider:physical_network=physnet1 --provider:network_type=flat --shared
neutron subnet-create flat-network 192.168.5.0/24 --name flat-subnet

# create key (make sure to ssh-keygen first)
echo "Importing ssh key for VMs"
ssh-keygen -t rsa -N "" -f /root/.ssh/id_rsa
openstack keypair create --public-key /root/.ssh/id_rsa.pub test-key
