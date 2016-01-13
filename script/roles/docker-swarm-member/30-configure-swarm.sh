#!/bin/bash

ip_re='(([0-9]+\.){3}[0-9]+)/[0-9]{,2}'

[[ $(ip -4 -o addr show scope global) =~ $ip_re ]] || exit 1
PORT=$(read_attribute docker/port)
host_addr=$(read_attribute consul/bind_addr)

if which systemctl >/dev/null 2>/dev/null ; then
    cat >/etc/systemd/system/docker-swarm-agent.service <<EOF
[Unit]
Description=Docker Swarm Local Agent
Documentation=https://docs.docker.com/swarm/
After=docker.service

[Service]
Type=simple
EnvironmentFile=-/etc/sysconfig/docker-swarm
ExecStart=/usr/local/bin/swarm join \
          --addr=$host_addr:${PORT} \
          consul://127.0.0.1:8500/docker-swarm

[Install]
WantedBy=multi-user.target
EOF

    systemctl daemon-reload
    systemctl enable docker-swarm-agent
    systemctl restart docker-swarm-agent

elif which chkconfig >/dev/null 2>/dev/null ; then

    cat >/etc/init.d/docker-swarm-agent <<EOF
#!/bin/bash
#
#       /etc/rc.d/init.d/docker-swarm-agent
#
# chkconfig: 345 70 30
# description: Docker Swarm Agent
# processname: swarm

# Source function library.
. /etc/init.d/functions

LOCKFILE=/var/lock/subsys/docker-swarm-agent

start() {
        PID=\`ps auxwww | grep "swarm join" | grep -v grep | awk '{ print \$2 }'\`
        if [ "\$PID" != "" ] ; then
             return 0
        fi
        echo -n "Starting Docker Swarm Agent: "
        daemon /usr/local/bin/swarm join \
          --addr=$host_addr:$PORT \
          consul://127.0.0.1:8500/docker-swarm >/var/log/docker-swarm-agent.log 2>&1 &
        RETVAL=\$?
        [ \$RETVAL -eq 0 ] && touch \$LOCKFILE
        echo
        return \$RETVAL
}

stop() {
        echo -n "Shutting down Docker Swarm Agent: "

        PID=\`ps auxwww | grep "swarm join" | grep -v grep | awk '{ print \$2 }'\`
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
        ps auxwww | grep "swarm join" | grep -v grep
        ;;
    restart)
        stop
        start
        ;;
    condrestart)
        [ -f /var/lock/subsys/docker-swarm-agent ] && restart || :
        ;;
    *)
        echo "Usage: docker-swarm-agent {start|stop|status|restart}"
        exit 1
        ;;
esac
exit \$?

EOF
    chmod +x /etc/init.d/docker-swarm-agent

    chkconfig --add docker-swarm-agent
    command service docker-swarm-agent restart
elif which initctl >/dev/null 2>/dev/null ; then

    cat >/etc/init/docker-swarm-agent.conf <<EOF
description "Start swarm manager on startup"
start on started networking

respawn
respawn limit 5 60

exec /usr/local/bin/swarm join \
          --addr=$host_addr:$PORT \
          consul://127.0.0.1:8500/docker-swarm >/var/log/docker-swarm-agent.log 2>&1

EOF

    command start docker-swarm-agent || command restart docker-swarm-agent

else
    echo "Unknown supported start system"
    exit 1
fi



