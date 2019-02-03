#!/bin/bash

source config

virsh list --all --name | grep "^${UNDR1}\.${NET}" > /dev/null
if [ $? -eq 0 ] ; then
  virsh destroy ${UNDR1}.${NET}
  virsh undefine --remove-all-storage ${UNDR1}.${NET}
  echo "virsh undefine --remove-all-storage ${UNDR1}.${NET}"
fi
