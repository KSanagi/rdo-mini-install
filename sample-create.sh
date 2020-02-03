#!/bin/bash

source overcloudrc
source config

openstack user create ocadmin --password openshiftpassword
openstack project create openshift
openstack role add --project openshift --user ocadmin admin

cat > openshiftrc << EOS 
unset OS_SERVICE_TOKEN
    export OS_USERNAME=ocadmin
    export OS_PASSWORD='openshiftpassword'
    export OS_AUTH_URL=$OS_AUTH_URL
    export PS1='[\u@\h \W(openshift_admin)]\$ '
    
export OS_PROJECT_NAME=openshift
export OS_USER_DOMAIN_NAME=Default
export OS_PROJECT_DOMAIN_NAME=Default
export OS_IDENTITY_API_VERSION=3
EOS
source openshiftrc
openstack keypair create --public-key /home/stack/.ssh/id_rsa.pub mykey

openstack security group create test
openstack security group rule create --ingress --protocol tcp --dst-port 22 test
openstack security group rule create --ingress --protocol icmp test
openstack security group rule create --egress test

openstack network create private
openstack subnet create private_subnet --network private \
                                --subnet-range 192.168.99.0/24 \
                                --dns-nameserver $DNS

openstack router create router1
openstack router set router1 --external-gateway public
openstack router add subnet router1 private_subnet

function create_cent_vm {
  VM=$1
  IP=$2
  PRIV_NET=$(openstack network show private -c id -f value)
  openstack floating ip create --floating-ip-address $IP public
  for i in `seq 5`; do
    openstack server create --flavor m1.small --image centos7 \
                            --security-group test \
                            --key-name mykey \
                            --nic net-id=$PRIV_NET \
                            --wait $VM
    openstack server add floating ip $VM $IP
    for j in `seq 30`; do
      sleep 10
      ssh centos@$IP "ping google.com -c 1"
      if [[ $? -eq 0 ]]; then return 0 ;fi
      echo "creating $VM $IP try=$i count=$j"
    done
    openstack server delete $VM
    sleep 10
  done
  return 1
}

create_cent_vm vm1 ${IP_PREFIX}.161
create_cent_vm vm2 ${IP_PREFIX}.162
