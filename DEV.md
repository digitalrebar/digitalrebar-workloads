## Step by step development instructions for the Mesosphere barclamp

### Start the Docker Admin, and enable some developer options.
1. Clone https://github.com/digitalrebar/core to $HOME/digitalrebar/core
2. Clone https://github.com/rackn/mesosphere to $HOME/digitalrebar/rackn/mesosphere
3. Clone https://github.com/rackn/hardware to $HOME/digitalrebar/hardware
4. ```rm -rf $HOME/digitalrebar/hardware/raid```
5. ```cd $HOME/digitalrebar/core/rackn/mesosphere```
6. ```./run_dev_cluster.sh```
7. Wait until the script says "Type 'done' to exit:".  Typing "done" will cleanly shut down the cluster and the whole development environment.
8. At that point, you will have the master nodes of the DCOS cluster set up, and can develop or troubleshoot from there.

