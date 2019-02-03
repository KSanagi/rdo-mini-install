#!/bin/bash

LANG=C
source config

./clean-nodes.sh
./create-nodes.sh

./create-vm.sh ${UNDR1}.$NET "${UNDR1_MAC}" "${UNDR1_MAC2}" 8192

# checking if UNDR1 booted up and is ready to be sshed
for i in `seq 30`; do
  echo "$UNDR1_IP checking...count=$i"
  ssh -q $UNDR1_IP "ls > /dev/null"
  if [[ $? -eq 0 ]]; then break ;fi
  sleep 10
done

scp init.sh config $UNDR1_IP:/root
ssh $UNDR1_IP   "/root/init.sh | tee log-init.txt"

for i in `seq 30`; do
  sleep 10
  echo "$UNDR1_IP checking...count=$i"
  ssh -q $UNDR1_IP "ls > /dev/null"
  if [[ $? -eq 0 ]]; then break ;fi
done

scp config stack@$UNDR1_IP:~
ssh stack@$UNDR1_IP 'openstack undercloud install 2>&1 | tee log-undercloud-install.txt'

#scp vlan-up.sh root@$UNDR1_IP:~
#ssh root@$UNDR1_IP '/root/vlan-up.sh'

scp deploy-overcloud.sh instackenv.json stack@$UNDR1_IP:~
ssh stack@$UNDR1_IP './deploy-overcloud.sh'

scp sample-base.sh sample-create.sh sample-delete.sh stack@$UNDR1_IP:~
ssh stack@$UNDR1_IP './sample-base.sh'
