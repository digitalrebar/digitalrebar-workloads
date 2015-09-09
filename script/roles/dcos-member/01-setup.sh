#!/bin/bash

# Untar the bootstrap tarball ourselves to alleviate the need for setting up an http server
share="$(read_attribute 'dcos/config/exhibitor_fs_config_dir')"


mkdir -p /opt/mesosphere
latest="$(ls -cN1 "$share/genconf/serve/bootstrap/"*.tar.xz |head -1)"

if ! [[ -f $share/genconf/serve/bootstrap/$latest ]]; then
    echo "Could not find latest bootstrap tarball!"
    exit 1
fi

tar -axf "$share/genconf/serve/bootstrap/$latest" -C /opt/mesosphere

# Bootstrap!
roles="$(read_attribute 'dcos/config/roles' |jq -r '.[]')"
bash -x /var/exports/genconf/serve/dcos_install.sh $roles
