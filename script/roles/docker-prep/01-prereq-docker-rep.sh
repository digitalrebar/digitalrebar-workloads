#!/bin/bash
if [[ -f /etc/os-release ]]; then
  . /etc/os-release
fi

docker_port=$(read_attribute "docker/port")
docker_cert_path=$(read_attribute "docker/cert_path")
docker_version=$(read_attribute "docker/version")
url_version="get"
if [[ $docker_version == latest ]] ; then
  url_version="get"
fi
if [[ $docker_version == release-candidate ]] ; then
  url_version="test"
fi
if [[ $docker_version == experimental ]] ; then
  url_version="experimental"
fi

if ! which docker; then
    # install docker using download script
    
    curl -sSL https://${url_version}.docker.com/ | bash
else
    echo "docker already installed, skipping"
fi

# Install python API
if ! which pip; then
    curl https://bootstrap.pypa.io/get-pip.py -o /tmp/get-pip.py
    python /tmp/get-pip.py
fi
if ! pip show docker-py; then
    pip install docker-py
else
    echo "docker python API already installed, skipping"
fi

MY_OPTIONS=""
# Setup docker access ports
if [[ $docker_port -ne 0 ]] ; then
  MY_OPTIONS="$MY_OPTIONS -H tcp://0.0.0.0:$docker_port"

  # if centos/redhat firewall - add port
  if which firewall-cmd ; then
    firewall-cmd --add-port $docker_port/tcp
  fi

  echo "DOCKER_HOST=127.0.0.1:$docker_port" >> /etc/environment
  echo "export DOCKER_HOST=127.0.0.1:$docker_port" > /etc/profile.d/docker_host.sh
  chmod +x /etc/profile.d/docker_host.sh
  . /etc/profile.d/docker_host.sh
fi

# Setup selinux options
if [[ -f /etc/redhat-release || -f /etc/centos-release ]]; then
  if [[ $(getenforce) == Enabled ]] ; then
    MY_OPTIONS="$MY_OPTIONS --selinux-enabled"
  fi
fi

# Update the OPTIONS variable
if [ "$MY_OPTIONS" != "" ] ; then
  if [[ -f /etc/redhat-release || -f /etc/centos-release ]]; then
    if [[ -d /etc/systemd ]]; then
      echo "OPTIONS=\"${MY_OPTIONS}\"" >> /etc/sysconfig/docker
      systemctl daemon-reload
    else
      echo "OPTIONS=\"${MY_OPTIONS}\"" >> /etc/sysconfig/docker
      echo "export OPTIONS" >> /etc/sysconfig/docker
      echo "other_args=\"${MY_OPTIONS}\"" >> /etc/sysconfig/docker
    fi
  elif [[ -d /etc/apt ]]; then
    echo "export DOCKER_OPTS=\"${DOCKER_OPTS} ${MY_OPTIONS}\"" >> /etc/default/docker
  fi
fi

# Update the DOCKER_CERT_PATH variable
if [ "$docker_cert_path" != "" ] ; then
  if [[ -f /etc/redhat-release || -f /etc/centos-release ]]; then
    if [[ -d /etc/systemd ]]; then
      echo "DOCKER_CERT_PATH=\"${docker_cert_path}\"" >> /etc/sysconfig/docker
      systemctl daemon-reload
    else
      echo "DOCKER_CERT_PATH=\"${docker_cert_path}\"" >> /etc/sysconfig/docker
      echo "export DOKER_CERT_PATH" >> /etc/sysconfig/docker
    fi
  elif [[ -d /etc/apt ]]; then
    echo "export DOKER_CERT_PATH=\"${docker_cert_path}\"" >> /etc/default/docker
  fi
fi

# Make sure we have a docker service file that can process options.
if [[ -f /etc/redhat-release || -f /etc/centos-release ]]; then
  if [[ -d /etc/systemd ]]; then
      mkdir -p /etc/systemd/system
      cat > /etc/systemd/system/docker.service <<EOF
[Service]
EnvironmentFile=-/etc/sysconfig/docker
EnvironmentFile=-/etc/sysconfig/docker-storage
EnvironmentFile=-/etc/sysconfig/docker-network
ExecStart=/usr/bin/docker daemon \$OPTIONS \
          \$DOCKER_STORAGE_OPTIONS \
          \$DOCKER_NETWORK_OPTIONS \
          \$BLOCK_REGISTRY \
          \$INSECURE_REGISTRY
EOF
      systemctl daemon-reload
  fi
fi

# setup proxy if defined
if [ "$http_proxy" != "" ] ; then
  if [[ -f /etc/redhat-release || -f /etc/centos-release ]]; then
    if [[ -d /etc/systemd ]]; then
        if [[ ! -f /etc/systemd/system/docker.service.d/http-proxy.conf ]]; then
            mkdir -p /etc/systemd/system/docker.service.d
            echo "[Service]" > /etc/systemd/system/docker.service.d/http-proxy.conf
            echo "Environment=\"HTTP_PROXY=${http_proxy}\" \"HTTPS_PROXY=${https_proxy}\" \"NO_PROXY=${no_proxy}\"" >> /etc/systemd/system/docker.service.d/http-proxy.conf
            systemctl daemon-reload
        else
            echo "docker proxy already set, skipping"	
        fi
    else
	echo "http_proxy=\"${http_proxy}\"" >> /etc/sysconfig/docker
	echo "export http_proxy" >> /etc/sysconfig/docker
	echo "https_proxy=\"${https_proxy}\"" >> /etc/sysconfig/docker
	echo "export https_proxy" >> /etc/sysconfig/docker
	echo "no_proxy=\"${no_proxy}\"" >> /etc/sysconfig/docker
	echo "export no_proxy" >> /etc/sysconfig/docker
    fi
  elif [[ -d /etc/apt ]]; then
    echo "export http_proxy=\"${http_proxy}\"" >> /etc/default/docker
    echo "export https_proxy=\"${https_proxy}\"" >> /etc/default/docker
    echo "export no_proxy=\"${no_proxy}\"" >> /etc/default/docker
  fi
fi

# bounce to be safe - not all install methods start the service.
service docker restart

