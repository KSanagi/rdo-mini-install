#!/bin/bash

source overcloudrc
source config

curl http://download.cirros-cloud.net/0.4.0/cirros-0.4.0-x86_64-disk.img -o cirros-0.4.0-x86_64-disk.img
curl https://cloud.centos.org/centos/7/images/CentOS-7-x86_64-GenericCloud-1809.qcow2.xz | xzcat > centos7.qcow2

for i in `seq 30`; do
  openstack server list > /dev/null
  if [[ $? -eq 0 ]]; then break ;fi
  echo "wait until openstack server list success count=$i"
  sleep 10
done

openstack image create "cirros" --file cirros-0.4.0-x86_64-disk.img --disk-format qcow2 --container-format bare --public
openstack image create "centos7" --file ./centos7.qcow2 --disk-format qcow2 --container-format bare --public

openstack flavor create m1.tiny    --ram 512  --disk  0 --vcpus 1
openstack flavor create m1.small   --ram 2048 --disk 20 --vcpus 1
openstack flavor create m1.medium  --ram 4096 --disk 40 --vcpus 2
openstack flavor create m1.large   --ram 8192 --disk 80 --vcpus 4

openstack network create public --provider-physical-network datacentre \
                                --provider-network-type flat \
                                --external --share
openstack subnet create public_subnet --network public \
                               --subnet-range ${IP_PREFIX}.128/25 \
                               --allocation-pool start=${IP_PREFIX}.130,end=${IP_PREFIX}.199 \
                               --dns-nameserver $DNS \
                               --gateway ${IP_PREFIX}.200 \
                               --no-dhcp
