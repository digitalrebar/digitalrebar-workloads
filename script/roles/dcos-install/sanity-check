#!/bin/bash
set +e +x
services=($(cd /etc/systemd/system/dcos.target.wants; echo *.service))

finshed=false

timeout=600

while (( timeout > 0 )); do
    outlog=()
    [[ $finished = true ]] && break
    finished=true
    for service in "${services[@]}"; do
        systemctl is-enabled --quiet $service || continue
        status=$(systemctl is-active $service || :)
        case $status in
            failed)
                finished=false
                outlog+=("Failed to start a required DCOS service: $service");;
            *active)
                outlog+=("Required DCOS service started: $service");;
            *)
                finished=false
                outlog+=("Waiting on required DCOS service: $service. Status: $status");;
        esac
    done
    [[ $finished == true ]] && break
    sleep 5
    timeout=$((timeout - 5))
done
printf '%s\n' "${outlog[@]}"
[[ $finished == true ]]
