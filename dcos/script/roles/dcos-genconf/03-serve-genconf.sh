#!/bin/bash

cd "$HOME"
gc_port=16034
if [[ ! -x /usr/local/bin/sws ]]; then
    curl -fgL https://s3-us-west-2.amazonaws.com/rebar-sws/sws-linux-amd64 -o /usr/local/bin/sws
    chmod 755 /usr/local/bin/sws
fi

if [[ ! -f /etc/systemd/system/sws-dcos.service ]]; then
    cat >/etc/systemd/system/sws-dcos.service <<EOF
[Unit]
Description=SWS static web serving for DCOS
Documentation=http://github.com/digitalrebar
After=sshd.service

[Service]
Type=simple
ExecStart=/usr/local/bin/sws -listen=:$gc_port -site=$HOME/genconf/serve

[Install]
WantedBy=multi-user.target

EOF
    systemctl daemon-reload
    systemctl enable sws-dcos
    systemctl start sws-dcos
fi
