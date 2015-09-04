#!/bin/bash

username=$(read_attribute 'dcos/genconf/docker_user')
password=$(read_attribute 'dcos/genconf/docker_password')
email=$(read_attribute 'dcos/genconf/docker_email')
image=$(read_attribute 'dcos/genconf/docker_image')

if ! [[ $username && $password && $email ]]; then
    echo "Must supply username, email, and password!"
    exit 1
fi

docker login -u "$username" -p "$password" -e "$email"
docker pull "$image"
