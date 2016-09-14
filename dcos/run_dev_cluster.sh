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

[[ $MASTER_NODES ]] || MASTER_NODES=3
[[ $SLAVE_NODES ]] ||SLAVE_NODES=0
 [[ $SLAVE_PUBLIC_NODES ]] || SLAVE_PUBLIC_NODES=2

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

cleanup() {
    res=$?
    set +e
    trap - 0 INT QUIT TERM
    while read -p "Type 'done' to exit: " finished && [[ $finished != "done" ]]; do
        sleep 5
    done
    pkill kvm-slave
    tear_down_admin_containers
    exit $res
}

trap cleanup 0 INT QUIT TERM

# We always want a provisioner and a forwarder
docker_admin_default_containers

bring_up_admin_containers && wait_for_admin_containers || \
        die "Failed to deploy admin node"

echo "Creating DCOS deployment"
depl_id=$(rebar deployments create '{"name": "dcos"}'|jq -r '.id')

TOTAL_NODES=$((MASTER_NODES + SLAVE_NODES + SLAVE_PUBLIC_NODES))
echo "Spawning $TOTAL_NODES for DCOS ($MASTER_NODES masters, $SLAVE_NODES slaves, $SLAVE_PUBLIC_NODES public slaves)"

for ((spawned_nodes = 0; spawned_nodes < TOTAL_NODES; spawned_nodes++)); do
    SLAVE_MEM=4G "$mountdir/core/tools/kvm-slave" &
done

echo "Waiting on spawned nodes to become alive and available"
while true; do
    spawned_nodes=( $(rebar nodes list |jq -r 'map(select(.["bootenv"] == "sledgehammer")) | .[] | .["name"]') )
    [[ ${#spawned_nodes[@]} = $TOTAL_NODES ]] && break
    sleep 5
done

rebar converge

echo "Moving nodes to DCOS deployment"

for n in "${spawned_nodes[@]}"; do
    rebar nodes update "$n" "{\"deployment_id\": $depl_id}"
done

echo "Configuring genconf node"
gc_node="$spawned_nodes"
gc_node_addr="$(rebar nodes addresses "$gc_node" on admin-internal |jq -r '.addresses | .[0]')"
rebar nodes bind "$gc_node" to dcos-genconf

masters=()
for idx in "${!spawned_nodes[@]}"; do
    node="${spawned_nodes[idx]}"
    role=slave
    if ((idx < MASTER_NODES)); then
        role=master
        addr="$(rebar nodes addresses "$node" on admin-internal |jq -r '.addresses | .[0]')"
        if [[ $addr ]]; then
            masters+=("${addr%/*}")
        else
            echo "Node $node has no IPv4 admin address!"
            exit 1
        fi
    elif ((idx < (MASTER_NODES + SLAVE_PUBLIC_NODES) )); then
        role=slave-public
    fi
    rebar nodes bind "$node" to "dcos-$role"
done

masters="$(printf '\"%s\",' "${masters[@]}")"
masters="[${masters%,}]"
rebar deployments set dcos attrib dcos-master-list to "{\"value\": $masters}"

echo "Waiting for nodes to deploy"
rebar deployments commit dcos
sleep 5

if ! rebar converge; then
    echo "Masters failed to converge!"
fi
