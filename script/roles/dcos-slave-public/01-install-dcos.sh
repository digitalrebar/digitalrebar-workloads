#!/bin/bash

# install DCOS in the appropriate role
# dcos_install.sh is a little too paranoid, so...
export PS4='${BASH_SOURCE}@${LINENO}(${FUNCNAME[0]:-toplevel}): '
bash -x /var/exports/genconf/serve/dcos_install.sh slave_public
dcos-sanity-check
