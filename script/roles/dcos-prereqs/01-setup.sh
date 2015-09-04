#!/bin/bash

yum -y install wget docker
. /etc/profile
cat >/etc/sysconfig/docker <<EOF
OPTIONS='--selinux-enabled'
DOCKER_CERT_PATH=/etc/docker
GOTRACEBACK=crash
http_proxy='$http_proxy'
https_proxy='$https_proxy'
no_proxy='$no_proxy'
EOF

systemctl enable docker
## docker-storage-setup is incredibly harebrained about handing situations
# where there is little or no disk space on the root drive for a new LV.
# Also, it is a hard requirement of the RHEL/Centos docker, so the following does not work:
# systemctl disable docker-storage-setup
# Instead, disable it in a much more brutal fashion
cat >/usr/bin/docker-storage-setup <<EOF
#!/bin/bash
true
EOF
chmod 755 /usr/bin/docker-storage-setup
systemctl status docker || systemctl start docker
