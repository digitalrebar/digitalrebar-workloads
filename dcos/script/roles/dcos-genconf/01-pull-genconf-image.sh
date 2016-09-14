#!/bin/bash

installer=$(read_attribute 'dcos/genconf/installer')
checksum=$(read_attribute 'dcos/genconf/sha1sum')
str=$(printf "%s  %s" "$checksum" "${installer##*/}")

cd "$HOME"
if [[ ! -f ${installer##*/} ]] || ! sha1sum -c <<< "$str"; then
    while ! curl -fgLO "$installer"; do
        sleep 10
    done
fi

sha1sum -c <<< "$str" || exit 1
chmod 755 "${installer##*/}"
