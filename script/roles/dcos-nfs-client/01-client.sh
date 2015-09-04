#!/bin/bash

yum -y install nfs-utils
share=$(read_attribute 'dcos/exhibitor/shared_fs_configdir')
server=$(read_attribute 'dcos/exhibitor/nfs_server_addr')
#[ -f /run/rpcbind/rpcbind.xdr ] || touch /run/rpcbind/rpcbind.xdr
#[ -f /run/rpcbind/portmap.xdr ] || touch /run/rpcbind/portmap.xdr

if ! fgrep -q "$server:$share" /etc/fstab; then
    mkdir -p "$share"
    echo "$server:$share $share nfs defaults 0 2" >>/etc/fstab
    mount "$share"
fi
