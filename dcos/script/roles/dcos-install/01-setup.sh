#!/bin/bash

# Allow writes to resolv.conf
chattr -i /etc/resolv.conf

# Create the 'nogroup' group for the installer.
groupadd -f -r nogroup

cp "$TMPDIR/$ROLE/sanity-check" /usr/local/bin/dcos-sanity-check
chmod 755 /usr/local/bin/dcos-sanity-check

addrs=$(read_attribute 'hints/rebar/network/admin-internal/addresses')
ip_re='"(([0-9]+\.){3}[0-9]+)/[0-9]+"'
if [[ $addrs =~ $ip_re ]] ; then
    echo "${BASH_REMATCH[1]}" >/tmp/dcos_ip
else
    echo "Cannot find IP address of admin-internal network!"
fi

tmpdir=/tmp/dcos_install
mkdir -p "$tmpdir"
bootstrap=$(read_attribute "dcos/config/bootstrap_url")
cd "$tmpdir"
curl -fgLO "$bootstrap/dcos_install.sh"
