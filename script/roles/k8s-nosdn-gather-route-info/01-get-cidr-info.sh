#!/bin/bash

bin_dir=/opt/kubernetes/server/bin

echo -n "{" > /tmp/cidr.json
$bin_dir/kubectl get nodes \
  --output=jsonpath='{range .items[*]}{.status.addresses[?(@.type=="InternalIP")].address} {.spec.podCIDR} {"\n"}{end}' | while read ip cidr ; do
  echo -n "$COMMA \"$ip\": \"$cidr\"" >> /tmp/cidr.json
  COMMA=","
done
echo "}" >> /tmp/cidr.json

write_attribute_file_content "k8s/nosdn/cidr_map" /tmp/cidr.json

rm -f /tmp/cidr.json

