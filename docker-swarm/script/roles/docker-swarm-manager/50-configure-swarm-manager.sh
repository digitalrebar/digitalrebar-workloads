#!/bin/bash

# Listen from everywhere - helps with vagrant and cloud.
swarm_addr="0.0.0.0"

M_PORT=$(read_attribute docker_swarm/manager_port)
host_addr=$(read_attribute consul/bind_addr)


if which systemctl >/dev/null 2>/dev/null ; then
    cat >/etc/systemd/system/docker-swarm-manager.service <<EOF
[Unit]
Description=Docker Swarm Management Agent
Documentation=https://docs.docker.com/swarm/
After=docker.service

[Service]
Type=simple
EnvironmentFile=-/etc/sysconfig/docker-swarm
ExecStart=/usr/local/bin/swarm manage \
          --host=$(addr_port $swarm_addr $M_PORT) \
          --replication --addr=$(addr_port $host_addr $M_PORT) \
          consul://127.0.0.1:8500/docker-swarm

[Install]
WantedBy=multi-user.target
EOF

    systemctl daemon-reload
    systemctl enable docker-swarm-manager
    systemctl restart docker-swarm-manager

elif which chkconfig >/dev/null 2>/dev/null ; then

    cat >/etc/init.d/docker-swarm-manager <<EOF
#!/bin/bash
#
#       /etc/rc.d/init.d/docker-swarm-manager
#
# chkconfig: 345 70 30
# description: Docker Swarm Manager
# processname: swarm

# Source function library.
. /etc/init.d/functions

LOCKFILE=/var/lock/subsys/docker-swarm-manager

start() {
        PID=\`ps auxwww | grep "swarm manage" | grep -v grep | awk '{ print \$2 }'\`
        if [ "\$PID" != "" ] ; then
             return 0
        fi
        echo -n "Starting Docker Swarm Manager: "
        daemon /usr/local/bin/swarm manage \
          --host=$(addr_port $swarm_addr $M_PORT) \
          --replication --addr=$(addr_port $host_addr $M_PORT) \
          consul://127.0.0.1:8500/docker-swarm > /var/log/docker-swarm-manager 2>&1 &
        RETVAL=\$?
        [ \$RETVAL -eq 0 ] && touch \$LOCKFILE
        echo
        return \$RETVAL
}

stop() {
        echo -n "Shutting down Docker Swarm Manager: "

        PID=\`ps auxwww | grep "swarm manage" | grep -v grep | awk '{ print \$2 }'\`
        if [ "\$PID" != "" ] ; then
            kill \$PID
            RETVAL=\$?
            [ \$RETVAL -eq 0 ] && rm -f \$LOCKFILE
        fi
        echo
        return \$RETVAL
}

case "\$1" in
    start)
        start
        ;;
    stop)
        stop
        ;;
    status)
        ps auxwww | grep "swarm manage" | grep -v grep
        ;;
    restart)
        stop
        start
        ;;
    condrestart)
        [ -f /var/lock/subsys/docker-swarm-manager ] && restart || :
        ;;
    *)
        echo "Usage: docker-swarm-manager {start|stop|status|restart}"
        exit 1
        ;;
esac
exit \$?

EOF

    chmod +x /etc/init.d/docker-swarm-manager
    chkconfig --add docker-swarm-manager
    command service docker-swarm-manager restart

elif which initctl >/dev/null 2>/dev/null ; then

    cat >/etc/init/docker-swarm-manager.conf <<EOF
description "Start swarm manager on startup"
start on started networking

respawn
respawn limit 5 60

exec /usr/local/bin/swarm manage \
          --host=$(addr_port $swarm_addr $M_PORT) \
          --replication --addr=$(addr_port $host_addr $M_PORT)  \
          consul://127.0.0.1:8500/docker-swarm > /var/log/docker-swarm-manager 2>&1
EOF

    command start docker-swarm-manager || command restart docker-swarm-manager

else
    echo "Unknown supported start system"
    exit 1
fi

# if centos/redhat firewall - add port
if which firewall-cmd ; then
    firewall-cmd --add-port $M_PORT/tcp || :
fi

