#!/bin/bash
# Set up a stupid NFS server for DCOS
share=$(get_attribute 'dcos/exhibitor/shared_fs_configdir')
network=$(get_attribute 'dcos/exhibitor/nfs_network')
mkdir -p "$share"
chmod 0777 "$share"
yum -y install nfs-utils
cat >/etc/exports <<EOF
$share $network(rw,fsid=root,no_subtree_check)
EOF
systemctl enable nfs-server
systemctl status nfs-server || systemctl start nfs-server
exportfs -rav
