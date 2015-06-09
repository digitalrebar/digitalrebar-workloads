#!/bin/bash

cat >/etc/profile.d/gopath.sh <<EOF
export GOPATH=\$HOME/go
mkdir -p "\$GOPATH"
pathmunge "\$GOPATH/bin" after
EOF
