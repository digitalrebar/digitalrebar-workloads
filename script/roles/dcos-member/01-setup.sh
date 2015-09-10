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

# Bootstrap!
roles="$(read_attribute 'dcos/member_roles' |jq -r '.[]')"
if [[ ! $roles ]]; then
    echo "No DCOS roles assigned for this node!"
    exit 1
fi

addrs=$(read_attribute 'hints/crowbar/network/the_admin/addresses')
ip_re='"(([0-9]+\.){3}[0-9]+)/[0-9]+"'
if [[ $addrs =~ $ip_re ]] ; then
    echo "${BASH_REMATCH[1]}" >/tmp/dcos_ip
else
    echo "Cannot find IP address of the_admin network!"
fi
# dcos_install.sh is a little too paranoid, so...
export PS4='${BASH_SOURCE}@${LINENO}(${FUNCNAME[0]:-toplevel}): '
bash -x /var/exports/genconf/serve/dcos_install.sh $roles
