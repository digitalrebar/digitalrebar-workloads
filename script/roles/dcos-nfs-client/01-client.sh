#!/bin/bash

yum -y install nfs-utils
share=$(get_attribute 'dcos/exhibitor/shared_fs_configdir')
server=$(get_attribute 'dcos/exhibitor/nfs_server')
if ! fgrep -q "$server:$share" /etc/fstab; then
    mkdir -p "$share"
    echo "$server:$share $share nfs4 defaults 0 2" >>/etc/fstab
    mount "$share"
fi
