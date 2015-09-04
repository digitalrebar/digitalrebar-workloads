#!/bin/bash
image=$(read_attribute 'dcos/genconf/docker_image')
share=$(read_attribute 'dcos/exhibitor/shared_fs_configdir')
PARAMS=("bootstrap_url" "cluster_name" "exhibitor_fs_config_dir"
        "exhibitor_storage_backend" "ip_detect_filename" "master_lb"
        "num_masters" "release_name" "repository_url":"https://10.10.20.1/dcos"
        "resolvers" "roles" "weights")

declare -A PARAMS_HASH

if [[ ! -d $share ]]; then
    echo "Mounted NFS filesystem at $share does not exist!"
    exit 1
fi

mkdir "$share/genconf.working"
# This needs to be updated to use the actual IP address we want.
echo '#!/bin/true' > "$share/genconf.working/ip-detect.sh"

# Extract the DCOS config using jq
jq '.dcos.config' <"$TMPDIR/attrs.json" >"$share/genconf.working"

# To be continued.
exit 1

