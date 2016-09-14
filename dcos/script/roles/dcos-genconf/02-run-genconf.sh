#!/bin/bash
set -o pipefail
nameservers="$(jq -c '[.[] |.address]' < <(read_attribute 'rebar/dns/nameservers'))"
installer=$(read_attribute 'dcos/genconf/installer')
addrs=$(read_attribute 'hints/rebar/network/admin-internal/addresses')
ip_re='"(([0-9]+\.){3}[0-9]+)/[0-9]+"'
if [[ $addrs =~ $ip_re ]] ; then
    addr="${BASH_REMATCH[1]}"
else
    echo "Cannot find IP address of admin-internal network!"
    exit 1
fi
gc_port=16034
bootstrap_url="http://${addr}:${gc_port}"
write_attribute 'dcos/config/bootstrap_url' "$bootstrap_url"
[[ -d $HOME/genconf ]] && exit
[[ -d $HOME/working ]] && rm -rf "$HOME/working"
mkdir -p "$HOME/working/genconf"
    
# This needs to be updated to use the actual IP address we want.
cat > "$HOME/working/genconf/ip-detect" <<EOF
#!/bin/bash
if ! [[ -f /tmp/dcos_ip ]]; then
    echo "IP not recorded!"
    exit 1
fi
cat /tmp/dcos_ip
EOF

chmod 755 "$HOME/working/genconf/ip-detect"

# Extract the DCOS config using jq
jq '.dcos.config' <"$TMPDIR/attrs.json" | \
    jq ".resolvers = $nameservers" | \
    jq ".bootstrap_url = \"$bootstrap_url\"" \
       >"$HOME/working/genconf/config.yaml"

cd "$HOME/working" && "$HOME/${installer##*/}" || exit 1

mv "$HOME/working/genconf" "$HOME/genconf"
rm -rf "$HOME/working"

