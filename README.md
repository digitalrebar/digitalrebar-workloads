This is the docker barclamp for RackN Enterprise. 

## Requirements and restrictions ##

* No custom networking or storage configurations are supported
* OS support is what the Docker install script supports, but we haven't validated all of them.

Currently, this barclamp installs:

* docker version latest, but variables choose release-candidate or experimental

## Quick start instructions ##

1. Clone this barclamp to a Rebar admin node.
2. Install it with ```rebar barclamps install /path/to/docker```
3. Add the ```docker-ready``` role to nodes that need docker.

## Roles this barclamp provides ##
### docker-ready

The ```docker-ready``` role is responsible for pulling in all the required pieces to run docker.  It is a milestone role.

### docker-prep

The ```docker-prep``` role is responsible for actually installing docker at the correct level with the correct options.

The ```docker-prep``` role as two attributes to set.

| Attribute | Default | Notes |
| docker-version | latest | The docker version to install: latest, release-candidate, experimental |
| docker-port | 2375 | TCP port for the docker Daemon to listen on. Set to 0 to disable. |
| docker-cert-path | "" | The path to the docker cert directory.  Default of "" causes system defaults |

