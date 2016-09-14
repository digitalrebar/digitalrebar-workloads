#!/bin/bash

cat >/etc/yum.repos.d/docker.repo <<"EOF"
[docker]
name=Docker Repository
baseurl=https://yum.dockerproject.org/repo/main/centos/$releasever/
enabled=1
gpgcheck=1
gpgkey=https://yum.dockerproject.org/gpg
EOF

if ! [[ -b /dev/mapper/docker-pool ]]; then
    pvcreate /dev/sdb /dev/sdc /dev/sdd
    vgcreate docker /dev/sdb /dev/sdc /dev/sdd
    lvcreate -l 90%FREE -n pool docker
    lvconvert -y --zero n -c 512K --type thin-pool docker/pool
    cat >/etc/lvm/profile/docker-pool.profile <<EOF
activation {
    thin_pool_autoextend_threshold=80
    thin_pool_autoextend_percent=20
}
EOF
    lvchange --metadataprofile docker-pool docker/pool
fi


if [[ ! -f /etc/systemd/system/docker.service ]]; then
    cat > /etc/systemd/system/docker.service <<EOF
[Unit]
Description=Docker Application Container Engine
Documentation=https://docs.docker.com
After=network.target docker.socket
Requires=docker.socket

[Service]
Type=notify
# the default is not to use systemd for cgroups because the delegate issues still
# exists and systemd currently does not support the cgroup feature set required
# for containers run by docker
ExecStart=/usr/bin/docker daemon -H fd:// --storage-opt dm.fs=xfs --storage-opt dm.thinpooldev=/dev/mapper/docker-pool --storage-opt dm.use_deferred_removal=true
MountFlags=slave
LimitNOFILE=1048576
LimitNPROC=1048576
LimitCORE=infinity
TimeoutStartSec=0
# set delegate yes so that systemd does not reset the cgroups of docker containers
Delegate=yes

[Install]
WantedBy=multi-user.target
EOF
fi

if [[ ! -x /usr/bin/docker ]]; then
    yum -y install wget unzip ipset docker-engine
fi

systemctl enable docker
systemctl status docker || systemctl start docker
