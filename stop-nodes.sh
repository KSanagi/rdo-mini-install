#!/bin/bash

source config

for VM in $MACHINES; do
  virsh list --name | grep "^${VM}\.${NET}" > /dev/null
  if [ $? -eq 0 ] ; then
    if [ "$VM" == "${UNDR1}" ]; then
      continue
    fi
    virsh destroy ${VM}.${NET}
    echo "virsh destroy ${VM}.${NET}"
    sleep 1
  fi
done

