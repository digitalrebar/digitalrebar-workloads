#!/bin/bash

ip_re='(([0-9]+\.){3}[0-9]+)/[0-9]{,2}'

[[ $(ip -4 -o addr show scope global) =~ $ip_re ]] || exit 1
swarm_addr="${BASH_REMATCH[1]}"

M_PORT=$(read_attribute docker_swarm/manager_port)

cat >/etc/systemd/system/docker-swarm-manager.service <<EOF
[Unit]
Description=Docker Swarm Management Agent
Documentation=https://docs.docker.com/swarm/
After=docker.service

[Service]
Type=simple
EnvironmentFile=-/etc/sysconfig/docker-swarm
ExecStart=/usr/local/bin/swarm manage \
          --host=$swarm_addr:$M_PORT \
          --replication --addr=$swarm_addr:$M_PORT \
          consul://127.0.0.1:8500/docker-swarm

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable docker-swarm-manager
systemctl restart docker-swarm-manager
