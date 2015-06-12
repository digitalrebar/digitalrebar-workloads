This is the docker-swarm barclamp for RackN Enterprise, your one-stop solution for standing up highly available Docker Swarm clusters on bare metal.

This is a proof-of-concept barclamp, and is not recommended for use in production environments yet.

## Requirements and restrictions ##

* Minimum of 3 nodes for full redundancy.
* The only base OS supported is Centos 7.1 for now.
* No custom networking or storage configurations are supported
* Consul is the only supported docker-swarm discovery mechanism.

Currently, this barclamp installs:

* golang version 1.4.2
* docker version 1.6.0
* consul version version 0.5.2
* docker swarm version 0.3.0-rc2

## Quick start instructions ##

1. Clone this barclamp to a Crowbar admin node.
2. Install it with ```crowbar barclamps install /path/to/docker-swarm```
3. Create a new deployment for the swarm, and move the machines you want to be swarm members over to it.
4. Install Centos 7.1 on them.
5. Once the OS has finished installing, and the nodes have finished annealing, add the ```docker-swarm-member``` role to all of the nodes.  This will also pull in the ```consul``` and ```docker-swarm-install``` roles.
6. Consul needs at least 3 nodes operating in server mode for full failover redundancy.  The first node you added the ```docker-swarm-member``` role to is already configured to be a consul server, so pick two of the other consul noderoles, change their consul-mode attribute from ```client``` to ```server```, and save the changes.
7. Pick a node or three to add the docker-swarm-manager role to.  These nodes will be the ones you will talk to in order to spin up and manipulate Docker containers in the Swarm cluster.
8. Commit the deployment.  Once it has finished annealing, the docker-swarm cluster will be live and ready to use.


## Roles this barclamp provides ##
### docker-swarm-install

The ```docker-swarm-install``` role is responsible for installing the packages and programs that each node in the cluster will need.  It currently installs:

* Go version 1.4.2 from the centos virt repo @ http://cbs.centos.org/repos/virt7-release/
* Docker version 1.5.0 from the same repository
* Swarm version 0.3.0-rc2 from source @ https://github.com/docker/swarm

It has a single attribute named ```docker-swarm-version```, which controls what tag will be checked out and built from Github.

### docker-swarm-member

The ```docker-swarm-member``` role is responsible for configuring the node to participate in the swarm.  It configures Docker and is responsible for running swarm in join mode.  Right now, the only configurable attribute is ```docker-swarm-cluster-port```, which defaults to 2375.  Every node that you want to run containers on should be bound to ```docker-swarm-member```.

The ```docker-swarm-member``` role depends on the ```docker-swarm-install``` and ```consul``` roles.

### docker-swarm-manager

The ```docker-swarm-manager``` role is responsible for exposing the Swarm API to the outside world, which will present the cluster as a single resource to run containers on.  Right now, the only configurable attribute is ```docker-swarm-manager-port```, which defaults to 2475.  ```docker-swarm-manager``` is HA, and you should run it on at least 3 nodes.

## Future work ##

* Allow for customizable networking.  Right now, everything runs over the crowbar admin network, which is fine for a proof of concept, but not for production workloads.  RackN has a robust per-host physical network management story, which we can tie Swarm into for providing a scalable backend network for the swarm members along with a secure frontend network for the swarm managers.
* Perform automated per-node storage discovery management.  Right now, we let Docker default to devicemapper on a loopback file for per-node container image storage.  Setting up more advanced devicemapper configurations or using btrfs witn multiple devices is an obvious next step in handling per-node storage.
* Detect and assign labels to nodes based on interesting detected hardware and local node capabilities.
* Keep up with swarm development and expand our capabilities to match it.
