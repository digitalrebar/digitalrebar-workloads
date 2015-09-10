#!/bin/bash
set +e +x
services=($(cd /etc/systemd/system/dcos.target.wants; echo *.service))

finshed=false

while [[ $finished != true ]]; do
    finished=true
    for service in "${services[@]}"; do
        if ! systemctl is-enabled --quiet $service; then
            echo "Skipping disabled service $service"
            continue
        fi
        status=$(systemctl is-active $service || :)
        case $status in
            failed)
                failed=true
                echo "Failed to start a required DCOS service: $service";;
            active)
                echo "Required DCOS service started: $service";;
            *)
                finished=false
                echo "Waiting on required DCOS service: $service. Status: $status";;
        esac
    done
    if [[ $finished != true ]]; then
        echo "Waiting 5 seconds"
        sleep 5
    fi
    [[ $failed ]] && exit 1
done
