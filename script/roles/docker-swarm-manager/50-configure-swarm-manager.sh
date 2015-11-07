#!/bin/bash

ip_re='(([0-9]+\.){3}[0-9]+)/[0-9]{,2}'

[[ $(ip -4 -o addr show scope global) =~ $ip_re ]] || exit 1
swarm_addr="${BASH_REMATCH[1]}"

M_PORT=$(read_attribute docker_swarm/manager_port)


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
          --host=$swarm_addr:$M_PORT \
          --replication --addr=$swarm_addr:$M_PORT \
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
        PID=`ps auxwww | grep "swarm manage" | grep -v grep | awk '{ print $2 }'`
        if [ "$PID" != "" ] ; then
             return 0
        fi
        echo -n "Starting Docker Swarm Manager: "
        /usr/local/bin/swarm manage \
          --host=$swarm_addr:$M_PORT \
          --replication --addr=$swarm_addr:$M_PORT \
          consul://127.0.0.1:8500/docker-swarm &
        RETVAL=$?
        [ $RETVAL -eq 0 ] && touch $LOCKFILE
        echo
        return $RETVAL
}

stop() {
        echo -n "Shutting down Docker Swarm Manager: "

        PID=`ps auxwww | grep "swarm manage" | grep -v grep | awk '{ print $2 }'`
        if [ "$PID" != "" ] ; then
            kill $PID
            RETVAL=$?
            [ $RETVAL -eq 0 ] && rm -f $LOCKFILE
        fi
        echo
        return $RETVAL
}

case "$1" in
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
    *)
        echo "Usage: docker-swarm-manager {start|stop|status|restart}"
        exit 1
        ;;
esac
exit $?

EOF

    chkconfig --add docker-swarm-manager
    service restart docker-swarm-manager
else
    echo "Unknown supported start system"
    exit 1
fi

