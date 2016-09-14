#!/bin/bash

cd /tmp/dcos_install
# install DCOS in the appropriate role
# dcos_install.sh is a little too paranoid, so...
export PS4='${BASH_SOURCE}@${LINENO}(${FUNCNAME[0]:-toplevel}): '
bash -x dcos_install.sh slave
dcos-sanity-check
