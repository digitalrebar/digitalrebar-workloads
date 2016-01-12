#!/bin/bash

curl -fgL -o /tmp/go.tgz https://storage.googleapis.com/golang/go1.5.2.linux-amd64.tar.gz
tar -C /usr/local -xzf /tmp/go.tgz
rm /tmp/go.tgz

