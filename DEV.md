## Step by step development instructions for the Mesosphere barclamp

### Start the Docker Admin, and enable some developer options.
1. Clone https://github.com/opencrowbar/core to $HOME/opencrowbar/core
2. Clone https://github.com/rackn/mesosphere to $HOME/opencrowbar/rackn/mesosphere
3. Clone https://github.com/rackn/hardware to $HOME/opencrowbar/hardware
4. ```rm -rf $HOME/opencrowbar/hardware/raid```
5. ```cd $HOME/opencrowbar/core```
6. ```tools/docker-admin --hostname admin.smoke.test centos ./production.sh admin.smoke.test```
7. Browse to the web UI at http://$SERVER_IP:3000, login with crowbar/crowbar.  You may need to wait about 10 minutes for the crowbar UI to come up.
8. Click utilities -> session settings, uncheck ```System roles only```, and click ```Update```.
9. Click deployments -> system, and wait for all the checkmarks to turn green.


### Start the KVM Slaves that will become masters.

In another tmux window or SSH session, run the following commands:

1. ```cd $HOME/opencrowbar/core```
2. ```for n in 1 2 3; do SLAVE_MEM=8G tools/kvm-slave & done```
3. Browse back to the web UI, click deployments -> system, and wait for all 3 slaves to show up and their checkmarks to turn green.

### Bind the genconf node

1. Click Deployments, and add a new deployment named default.  This will take yo2 to the freshly-created default deployment.
3. In the role drop-down menu, select dcos-genconf, then click ```Add Role```.
4. Click ```Add Nodes```.  This will take you to the bulk edit screen.  Select a node besides the admin node, change its deployment to default, and click ```Save```.
5.  Click deployments -> default. You will notice that the nodes and roles form a grid.  Hover your mouse over the intersection of the node you selected and the ```dcos-genconf``` role.  A green + will appear, click it.  This will bind the ```dcos-genconf``` role and all its unbound prerequisites to the node.

### Set up some required attributes for NFS server and client configuration.

This section will go away once we are past PoC phase and I add the role intelligence to auto-populate things.

1. ```crowbar deployments set default attrib dcos-nfs-network to '{"value": "192.168.124.0/24"}'```
2. Look up the admin addresses of the node that genconf will run on: ```crowbar nodes get $node_name attrib network-the_admin_addresses```.  We want the IPv4 address in non-CIDR form.
3. ```crowbar deployments set default attrib dcos-nfs-server-ip to '{"value": "address-looked-up-in-last-step"}'```

### Set up some required attributes for the genconf node.

In another tmux window or SSH session, run the following commands:

1. ```export CROWBAR_KEY=crowbar:crowbar```
2. ```crowbar deployments set default attrib dcos-docker-genconf-user to '{"value": "user-with-access-to-mesosphere/dcos-genconf"}'```
3. ```crowbar deployments set default attrib dcos-docker-genconf-password to '{"value": "password-of-user"}'```
4. ```crowbar deployments set default attrib dcos-docker-genconf-email to '{"value": "email@user"}'```

# Commit the deployment

1. ```crowbar deployments commit default```


