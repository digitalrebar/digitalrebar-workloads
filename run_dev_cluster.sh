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
    set +e
    "$mountdir/core/tools/docker-admin-down"
    pkill kvm-slave
}
trap cleanup 0 INT QUIT TERM

"$mountdir/core/tools/docker-admin-up"
export REBAR_KEY=rebar:rebar1
export REBAR_ENDPOINT=http://127.0.0.1:3000

echo "Waiting for rebar to come up (1 or 2 minutes)"

count=240
while ! rebar ping &>/dev/null; do
    count=$((count - 1))
    if (( count == 0 )); then
        echo "Took too long for rebar to come up"
        exit 1
    fi
    sleep 1
done
echo "Waiting on the mesosphere barclamp to show up (30 seconds or so)"
count=120
while ! rebar barclamps show mesosphere &>/dev/null; do
    count=$((count - 1))
    if (( count == 0 )); then
        echo "Took too long for mesosphere to show up"
        exit 1
    fi
    sleep 1
done
echo "Waiting for provisioner (1 or 2 minutes)"
count=240
while ! rebar nodes show provisioner.local.neode.org &>/dev/null; do
    count=$((count - 1))
    if (( count == 0 )); then
        echo "Took too long for provisioner to show up"
        exit 1
    fi
    sleep 1
done

sleep 5
echo "Waiting for rebar to converge (up to 10 minutes)"
if ! rebar converge; then
    echo "Rebar failed to converge!"
    exit 1
fi

echo "Spawning 3 nodes for the DCOS Masters"

spawned_nodes=()

for n in 1 2 3; do
    pre_nodes="$(rebar nodes list |jq -r '.[] | .name' |sort)"
    SLAVE_MEM=8G "$mountdir/core/tools/kvm-slave" &
    echo "Waiting for node to appear in Rebar"
    while post_nodes="$(rebar nodes list |jq -r '.[] | .name' |sort)" && [[ $pre_nodes == $post_nodes ]]; do
        sleep 1
    done
    spawned_nodes+=($(sort <(echo "$pre_nodes") <(echo "$post_nodes") |uniq -u))
done

echo "Waiting on spawned nodes to become alive and available"
all_alive=false
while [[ $all_alive != true ]]; do
    all_alive=true
    for node in "${spawned_nodes[@]}"; do
        json="$(rebar nodes show "$node")"
        if jq '.alive, .available' <<< "$json" |grep -q "false"; then
            all_alive=false
            break
        fi
    done
    sleep 5
done

echo "Waiting on spawned nodes to finish Sledgehammer"
rebar converge

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

