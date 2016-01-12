#!/bin/bash
. /etc/profile
[[ -x /usr/local/bin/swarm ]] && return
install git
[[ -x $GOPATH/bin/godep ]] || go get github.com/tools/godep
mkdir -p "$GOPATH/src/github.com/docker/"
cd "$GOPATH/src/github.com/docker/"
if [[ -d swarm ]]; then
   cd swarm
   git fetch
else
    git clone https://github.com/docker/swarm
    cd swarm
fi
git checkout -f "$(read_attribute 'docker_swarm/version')"
$GOPATH/bin/godep go install
cp "$GOPATH/bin/swarm" /usr/local/bin/swarm

