## Step by step development instructions for the Mesosphere barclamp

### Start the Docker Admin, and enable some developer options.
1. Clone https://github.com/digitalrebar/core to $HOME/digitalrebar/core
2. Clone https://github.com/rackn/mesosphere to $HOME/digitalrebar/rackn/mesosphere
3. Clone https://github.com/rackn/hardware to $HOME/digitalrebar/hardware
4. ```rm -rf $HOME/digitalrebar/hardware/raid```
5. ```cd $HOME/digitalrebar/core/rackn/mesosphere```
6. ```.GENCONF_USER="user" GENCONF_EMAIL="mail@mesosphere.com" GENCONF_PASSWORD="password" ./run_dev_cluster.sh```  You will need to change the GENCONF_USER, GENCONF_EMAIL, and GENCONF_PASSWORD variables to ones that have access to the mesosphere/dcos-genconf container.
7. Wait until the script says "Type 'done' to exit:".  Typing "done" will shut down everything.
8. At that point, you will have 3 masters and 2 public slaves up and running, and from there you can play around (if no errors happened), or troubleshoot and rerun noderoles (if there were issues)

