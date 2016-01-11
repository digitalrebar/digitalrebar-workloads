#!/bin/bash

cat >/etc/profile.d/gopath.sh <<EOF

pathmunge () {
        if ! echo $PATH | /bin/egrep -q "(^|:)$1($|:)" ; then
           if [ "$2" = "after" ] ; then
              PATH=$PATH:$1
           else
              PATH=$1:$PATH
           fi
        fi
}

export GOPATH=\$HOME/go
mkdir -p "\$GOPATH"
pathmunge "\$GOPATH/bin" after
EOF
