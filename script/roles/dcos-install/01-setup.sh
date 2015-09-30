#!/bin/bash

# Untar the most recentbootstrap tarball ourselves to
# alleviate the need for setting up an http server
share="$(read_attribute 'dcos/config/exhibitor_fs_config_dir')"
bootstrap="$(read_attribute 'dcos/bootstrap_id')"
mkdir -p /opt/mesosphere
latest="$share/genconf/serve/bootstrap/$bootstrap"

if ! [[ -f $latest ]]; then
    echo "Could not find latest bootstrap tarball!"
    exit 1
fi

tar -axf "$latest" -C /opt/mesosphere

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
