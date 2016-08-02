#!/bin/bash

read_attribute_file_content "k8s/nosdn/cidr_map" "/tmp/cidr.json"

cat /tmp/cidr.json | jq -r 'keys|.[]' | while read key ; do
  cidr=$(jq -r ".[\"$key\"]" /tmp/cidr.json)

  # Don't add a route for ourselves
  if ip addr | grep -q " $key/" ; then
	  continue
  fi

  # remove conflicting
  if ip route | grep "^$cidr " ; then
    ip route del $cidr
  fi

  # Add route
  ip route add $cidr via $key

done


rm -rf /tmp/cidr.json

