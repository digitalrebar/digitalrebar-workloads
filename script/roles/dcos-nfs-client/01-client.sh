#!/bin/bash

yum -y install nfs-utils
share=$(read_attribute 'dcos/config/exhibitor_fs_config_dir')
server=$(read_attribute 'dcos/exhibitor/nfs_server_addr')

if ! fgrep -q "$server:$share" /etc/fstab; then
    mkdir -p "$share"
    echo "$server:$share $share nfs defaults 0 2" >>/etc/fstab
    mount "$share"
fi
