#!/bin/bash

source config

for VM in $MACHINES; do
  virsh list --all --name | grep "^${VM}\.${NET}" > /dev/null
  if [ $? -eq 0 ] ; then
    if [ "$VM" != "${UNDR1}" ]; then
      vbmc stop ${VM}.${NET}
      sleep 1
      vbmc delete ${VM}.${NET}
      sleep 1
    fi
    virsh destroy ${VM}.${NET}
    virsh undefine --remove-all-storage ${VM}.${NET}
    echo "virsh undefine --remove-all-storage ${VM}.${NET}"
    sleep 1
  fi
done

virsh net-list --all --name | grep "^${NET}$" > /dev/null
if [ $? -eq 0 ] ; then
  virsh net-destroy $NET
  virsh net-undefine $NET
  echo "virsh net-undefine $NET"
  sleep 1
fi

virsh net-list --all --name | grep "^${NET2}$" > /dev/null
if [ $? -eq 0 ] ; then
  virsh net-destroy $NET2
  virsh net-undefine $NET2
  echo "virsh net-undefine $NET2"
  sleep 1
fi
