#!/bin/bash
# Set up a stupid NFS server for DCOS
share=$(read_attribute 'dcos/config/exhibitor_fs_config_dir')
network=$(read_attribute 'dcos/exhibitor/nfs_network')
mkdir -p "$share"
chmod 0777 "$share"
yum -y install nfs-utils
cat >/etc/exports <<EOF
$share $network(rw,no_subtree_check)
EOF
for svc in rpcbind nfs-server; do
    systemctl enable $svc
    systemctl status $svc || systemctl start $svc
done
exportfs -rav
