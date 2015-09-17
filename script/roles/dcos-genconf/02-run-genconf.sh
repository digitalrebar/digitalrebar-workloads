#!/bin/bash
image=$(read_attribute 'dcos/genconf/docker_image')
share=$(read_attribute 'dcos/config/exhibitor_fs_config_dir')
nameservers="$(jq -c '[.[] |.address]' < <(read_attribute 'rebar/dns/nameservers'))"
nameservers="${nameservers//\"/\\\"}"
if [[ ! -d $share ]]; then
    echo "Mounted NFS filesystem at $share does not exist!"
    exit 1
fi

[[ -d $share/genconf ]] && exit

[[ -d $share/genconf.working ]] && rm -rf "$share/genconf.working"
mkdir "$share/genconf.working"
    
# This needs to be updated to use the actual IP address we want.
cat > "$share/genconf.working/ip-detect.sh" <<EOF
#!/bin/bash
if ! [[ -f /tmp/dcos_ip ]]; then
    echo "IP not recorded!"
    exit 1
fi
cat /tmp/dcos_ip
EOF

addrs=$(read_attribute 'hints/rebar/network/the_admin/addresses')
ip_re='"(([0-9]+\.){3}[0-9]+)/[0-9]+"'
if [[ $addrs =~ $ip_re ]] ; then
    addr="${BASH_REMATCH[1]}"
else
    echo "Cannot find IP address of the_admin network!"
fi

# Extract the DCOS config using jq
jq '.dcos.config' <"$TMPDIR/attrs.json" | \
    jq ".master_lb = \"$addr\"" |
    jq ".resolvers = \"$nameservers\"" >"$share/genconf.working/config-user.json" 

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

