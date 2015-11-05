#!/bin/bash

ip_re='(([0-9]+\.){3}[0-9]+)/[0-9]{,2}'

[[ $(ip -4 -o addr show scope global) =~ $ip_re ]] || exit 1
swarm_addr="${BASH_REMATCH[1]}"
PORT=$(read_attribute docker/port)

cat >/etc/systemd/system/docker-swarm-agent.service <<EOF
[Unit]
Description=Docker Swarm Local Agent
Documentation=https://docs.docker.com/swarm/
After=docker.service

[Service]
Type=simple
EnvironmentFile=-/etc/sysconfig/docker-swarm
ExecStart=/usr/local/bin/swarm join \
          --addr=$swarm_addr:${PORT} \
          consul://127.0.0.1:8500/docker-swarm

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable docker-swarm-agent
systemctl restart docker-swarm-agent
