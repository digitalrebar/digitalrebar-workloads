#!/bin/bash
set -o pipefail
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
cat > "$share/genconf.working/ip-detect" <<EOF
#!/bin/bash
if ! [[ -f /tmp/dcos_ip ]]; then
    echo "IP not recorded!"
    exit 1
fi
cat /tmp/dcos_ip
EOF

chmod 755 "$share/genconf.working/ip-detect"

addrs=$(read_attribute 'hints/rebar/network/admin-internal/addresses')
ip_re='"(([0-9]+\.){3}[0-9]+)/[0-9]+"'
if [[ $addrs =~ $ip_re ]] ; then
    addr="${BASH_REMATCH[1]}"
else
    echo "Cannot find IP address of admin-internal network!"
fi

# Extract the DCOS config using jq
jq '.dcos.config' <"$TMPDIR/attrs.json" | \
    jq ".resolvers = \"$nameservers\"" >"$share/genconf.working/config.json" 

# Build out the config we care about
if ! docker run -i -v "$share/genconf.working:/genconf" \
       -e "http_proxy=$http_proxy" \
       -e "https_proxy=$https_proxy" \
       -e "no_proxy=$no_proxy" \
       "$image" \
       -c /genconf/config.json >/tmp/genconf.out; then 
    echo "Genconf failed!"
    exit 1
fi

mv "$share/genconf.working" "$share/genconf"

write_attribute 'dcos/bootstrap_id' "$(jq -r '.bootstrap_id' "/tmp/genconf.out").bootstrap.tar.xz"

