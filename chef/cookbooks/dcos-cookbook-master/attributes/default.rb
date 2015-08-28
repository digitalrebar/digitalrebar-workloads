## TODO: port pilar settings to attributes
# dcos:
#   # A name for your DCOS cluster
#   cluster_name: DCOS
default['dcos']['cluster_name'] = 'DCOS'

#   # The quorum setting determins the number of masters
#   # in a quorum that have to be healthy for the cluster
#   # to be operational. It has to be the majority of
#   # nodes (n/2+1). E.g. if you have 3 master nodes you
#   # configure a quorum of 2. If you have 5 masters
#   # a quorum of 3, and so on.
#   quorum: 2
default['dcos']['quorum'] = 2

#   # The total number of master nodes
#   zookeeper_cluster_size: 3
default['dcos']['zookeeper_cluster_size'] = 3

#   # The fqdn or IP of your load balancer
#   # This has to balance the following tcp ports
#   # to all nodes with the master role:
#   # 80, 443, 8080, 8181, 2181, 5050
#   # For testing purpose or if you don't have
#   # a load balancer the fqdn of one of the masters
#   # will work as well. However not using a HA load
#   # balancer introduces a single point of failure.
#   master_lb: loadbalancer.corp.example.com
default['dcos']['master_lb'] = 'loadbalancer.corp.example.com'

# DCOS uses files in /etc/mesosphere/roles to determine how
# to set up the machine in dcos-service, we'll default to slave here.
# This is an array to accomodate multiple roles on a single host.
# valid options are 'master', 'slave', and 'slave_public'
default['dcos']['roles'] = ['slave']

#   # DCOS uses Exhibitor to dynamically add
#   # or remove Zookeeper nodes. To do so Exhibitor
#   # requires a file share to coordinate it's work
#   exhibitor:
#     # The share can either be an S3 bucket in
#     # which case you also need to configure AWS
#     # credentials below. The bucket has to exist.
#     # It will not be created!
#     aws_s3_bucket: dcos1-exhibitors3bucket
default['dcos']['exhibitor']['aws_s3_bucket'] = 'dcos1-exhibitors3bucket'
#     aws_s3_prefix: dcos1
default['dcos']['exhibitor']['aws_s3_prefix'] = 'dcos1'
#     web_ui_port: 8181
default['dcos']['exhibitor']['web_ui_port'] = 8181
#
#     # Or it can be a mounted NFS/CIFS/etc. share
#     # that's mounted to the same location on all
#     # master nodes. If the shared_fs_configdir is
#     # set all S3 settings are being ignored.
#     shared_fs_configdir:
default['dcos']['exhibitor']['shared_fs_configdir'] = nil

#   # DCOS comes with it's own internal DNS server
#   # However for resolving external hostnames one or more
#   # resolvers have to be configured.
#   dns:
#     resolvers:
#       - 8.8.8.8
#       - 8.8.4.4
default['dcos']['dns']['resolvers'] = ['8.8.8.8', '8.8.4.4']
#     fallback: 8.8.8.8
default['dcos']['dns']['fallback'] = '8.8.8.8'

#   # If you chose to use an S3 bucket for Exhibitor's
#   # configuration above configure the AWS credentials
#   # to write to the bucket here
#   aws:
#     region: eu-west-1
#     access_key_id: AKIAIQZB3XXXXXXXXXXX
#     secret_access_key: XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
default['dcos']['aws']['region'] = 'eu-west-1'
default['dcos']['aws']['access_key_id'] = 'AKIAIQZB3XXXXXXXXXXX'
default['dcos']['aws']['secret_access_key'] = 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'

#   ##### You should not have to change anything below this line #####
#   # Any of the settings below can be removed and defaults will be used

#   repository-url: https://downloads.mesosphere.io/dcos/stable
default['dcos']['repository-url'] = 'https://downloads.mesosphere.io/dcos/stable'

#   el-repo:
#     rpm: http://repos.mesosphere.io/dcos/el/7/noarch/RPMS/dcos-el-repo-7-0.el7.centos.noarch.rpm
default['dcos']['el-repo']['rpm'] = 'http://repos.mesosphere.io/dcos/el/7/noarch/RPMS/dcos-el-repo-7-0.el7.centos.noarch.rpm'
#     pubkey: http://repos.mesosphere.io/el/RPM-GPG-KEY-mesosphere
default['dcos']['el-repo']['pubkey'] = 'http://repos.mesosphere.io/el/RPM-GPG-KEY-mesosphere'
#     pubkey_hash: md5=b0496ec75eeca59bafc21d7639fa91dc
default['dcos']['el-repo']['pubkey_hash'] = '232cfc54f1b8f3d63a07993a72205eca878153bb58e5d0f1ad0bbfe7cb403d7d'

#   mesos:
#     master:
#       log_dir: /var/log/mesos
default['dcos']['mesos']['master']['log_dir'] = '/var/log/mesos'
#       work_dir: /var/lib/mesos/master
default['dcos']['mesos']['master']['work_dir'] = '/var/lib/mesos/master'
#       zk: zk://127.0.0.1:2181/mesos
default['dcos']['mesos']['master']['zk'] = 'zk://127.0.0.1:2181/mesos'
#       roles: slave_public
default['dcos']['mesos']['master']['roles'] = 'slave_public'

#     slave:
#       log_dir: /var/log/mesos
default['dcos']['mesos']['slave']['log_dir'] = '/var/log/mesos'
#       work_dir: /var/lib/mesos/slave
default['dcos']['mesos']['slave']['work_dir'] = '/var/lib/mesos/slave'
#       master: zk://leader.mesos:2181/mesos
default['dcos']['mesos']['slave']['master'] = 'zk://leader.mesos:2181/mesos'
#       containerizers: docker,mesos
default['dcos']['mesos']['slave']['containerizers'] = 'docker,mesos'
#       executor_registration_timeout: 5mins
default['dcos']['mesos']['slave']['executor_registration_timeout'] = '5mins'
#       isolation: cgroups/cpu,cgroups/mem
default['dcos']['mesos']['slave']['isolation'] = 'cgroups/cpu,cgroups/mem'
#       resources: ports:[1025-2180,2182-3887,3889-5049,5052-8079,8082-8180,8182-65535]
default['dcos']['mesos']['slave']['resources'] = 'ports:[1025-2180,2182-3887,3889-5049,5052-8079,8082-8180,8182-65535]'
#       subsystems: cpu,memory
default['dcos']['mesos']['slave']['subsystems'] = 'cpu,memory'

#     slave-public:
#       log_dir: /var/log/mesos
default['dcos']['mesos']['slave-public']['log_dir'] = '/var/log/mesos'
#       work_dir: /var/lib/mesos/slave-public
default['dcos']['mesos']['slave-public']['work_dir'] = '/var/lib/mesos/slave-public'
#       master: zk://leader.mesos:2181/mesos
default['dcos']['mesos']['slave-public']['master'] = 'zk://leader.mesos:2181/mesos'
#       containerizers: docker,mesos
default['dcos']['mesos']['slave-public']['containerizers'] = 'docker,mesos'
#       executor_registration_timeout: 5mins
default['dcos']['mesos']['slave-public']['executor_registration_timeout'] = '5mins'
#       isolation: cgroups/cpu,cgroups/mem
default['dcos']['mesos']['slave-public']['isolation'] = 'cgroups/cpu,cgroups/mem'
#       resources: ports:[1-21,23-5050,5052-65535]
default['dcos']['mesos']['slave-public']['resources'] = 'ports:[1-21,23-5050,5052-65535]'
#       subsystems: cpu,memory
default['dcos']['mesos']['slave-public']['subsystems'] = 'cpu,memory'
#       default_role: slave_public
default['dcos']['mesos']['slave-public']['default_role'] = 'slave_public'
#       attributes: public_ip:true
default['dcos']['mesos']['slave-public']['public_ip'] = true
