#!/bin/bash

yum -y install wget docker
systemctl enable docker
systemctl start docker
