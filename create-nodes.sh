#!/bin/bash

source config

./create-net.sh

./create-node.sh ${NODE1}.$NET "${NODE1_MAC}" "${NODE1_MAC2}" 192.168.23.111  8192
./create-node.sh ${NODE2}.$NET "${NODE2_MAC}" "${NODE2_MAC2}" 192.168.23.112  8192
./create-node.sh ${NODE3}.$NET "${NODE3_MAC}" "${NODE3_MAC2}" 192.168.23.113  8192
