#!/bin/bash
image=$(read_attribute 'dcos/genconf/docker_image')
share=$(read_attribute 'dcos/config/exhibitor_fs_config_dir')
if [[ ! -d $share ]]; then
    echo "Mounted NFS filesystem at $share does not exist!"
    exit 1
fi

[[ -d $share/genconf ]] && exit

[[ -d $share/genconf.working ]] && rm -rf "$share/genconf.working"
mkdir "$share/genconf.working"
    
# This needs to be updated to use the actual IP address we want.
echo '#!/bin/true' > "$share/genconf.working/ip-detect.sh"

# Extract the DCOS config using jq
jq '.dcos.config' <"$TMPDIR/attrs.json" >"$share/genconf.working/config-user.json"

# Build out the config we care about
docker run -i -v "$share/genconf.working:/genconf" \
       -e "http_proxy=$http_proxy" \
       -e "https_proxy=$https_proxy" \
       -e "no_proxy=$no_proxy" \
       mesosphere/dcos-genconf:db5602952daa-92358639efe9-671d4b52b24e \
       non-interactive

if ! [[ -f $share/genconf.working/config-final.json ]]; then
    echo "Could not find $share/genconf/config-final.json"
    exit 1
fi

mv "$share/genconf.working" "$share/genconf"

write_attribute 'dcos/bootstrap_id' "$(jq -r '.bootstrap_id' "$share/genconf/config-final.json").bootstrap.tar.xz"

