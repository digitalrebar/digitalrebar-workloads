#!/bin/bash
export PS4='${BASH_SOURCE}@${LINENO}(${FUNCNAME[0]}): '
set -e

if [[ $0 = /* ]]; then
    mountdir="$0"
elif [[ $0 = .*  || $0 = */* ]]; then
    mountdir="$(readlink -f "$PWD/$0")"
else
    echo "Cannot figure out where core is!"
    exit 1
fi

mountdir="${mountdir%/*}"

# Walk up the directory tree, and stop when we find $mountdir/core/tools/docker-admin-up

while [[ ! -x $mountdir/core/tools/docker-admin-up ]]; do
    mountdir="${mountdir%/*}"
    if [[ ! $mountdir ]]; then
        echo "Failed to find core repository!"
        exit 1
    fi
done

. "$mountdir/core/tools/da-lib.sh"

if ! [[ $GENCONF_USER && $GENCONF_EMAIL && $GENCONF_PASSWORD ]]; then
    echo "GENCONF_USER, GENCONF_EMAIL, and GENCONF_PASSWORD must be set"
    echo "They are required to allow the dcos-genconf role to download the"
    echo "DCOS configuration container from hub.docker.com."
    exit 1
fi

if ! which rebar &>/dev/null; then
    echo "Please install the rebar command with"
    echo "   go get -u github.com/digitalrebar/rebar-api/rebar"
    echo "and make sure $GOPATH/bin is in your \$PATH"
    exit 1
fi

cleanup() {
    res=$?
    set +e
    pkill kvm-slave
    tear_down_admin_containers
    exit $res
}
trap cleanup 0 INT QUIT TERM

bring_up_admin_containers && wait_for_admin_containers || \
        die "Failed to deploy admin node"

echo "Spawning 3 nodes for the DCOS Masters"

for n in 1 2 3; do
    pre_nodes="$(rebar nodes list |jq -r '.[] | .name' |sort)"
    SLAVE_MEM=8G "$mountdir/core/tools/kvm-slave" &
    sleep 15
done

echo "Waiting on spawned nodes to become alive and available"
rebar converge
spawned_nodes=( $(rebar nodes list |jq -r 'map(select(.["bootenv"] == "sledgehammer")) | .[] | .["name"]') )

echo "Creating DCOS deployment"
depl_id=$(rebar deployments create '{"name": "dcos"}'|jq -r '.id')

echo "Moving nodes to DCOS deployment"

for n in "${spawned_nodes[@]}"; do
    rebar nodes update "$n" "{\"deployment_id\": $depl_id}"
done

echo "Configuring genconf node"
gc_node="$spawned_nodes"
gc_node_addr="$(rebar nodes addresses "$gc_node" on admin-internal |jq -r '.addresses | .[0]')"
rebar nodes bind "$gc_node" to dcos-genconf
rebar deployments set dcos attrib dcos-nfs-network to '{"value": "192.168.124.0/24"}'
rebar deployments set dcos attrib dcos-nfs-server-ip to "{\"value\": \"${gc_node_addr%/*}\"}"
rebar deployments set dcos attrib dcos-docker-genconf-user to "{\"value\": \"$GENCONF_USER\"}"
rebar deployments set dcos attrib dcos-docker-genconf-email to "{\"value\": \"$GENCONF_EMAIL\"}"
rebar deployments set dcos attrib dcos-docker-genconf-password to "{\"value\": \"$GENCONF_PASSWORD\"}"

echo "Configuring master nodes"
for node in "${spawned_nodes[@]}"; do
    rebar nodes bind "$node" to dcos-member
    rebar nodes set "$node" attrib dcos-member-roles to '{"value": ["master"]}'
done

echo "Recording masters"
masters="$(printf "\\\\\"%s\\\\\"," "${spawned_nodes[@]}")"
masters="[${masters%,}]"
rebar deployments set dcos attrib dcos-master-list to "{\"value\": \"$masters\"}"


echo "Waiting for masters to deploy"
rebar deployments commit dcos
sleep 5

if ! rebar converge; then
    echo "Masters failed to converge!"
fi

# Add code for slave bringup here

while read -p "Type 'done' to exit: " finished && [[ $finished != "done" ]]; do
    sleep 5
done

