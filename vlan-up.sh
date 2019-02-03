#!/bin/bash

cat > /etc/sysconfig/network-scripts/ifcfg-vlan10 << EOS
DEVICE=vlan10
ONBOOT=yes
HOTPLUG=no
TYPE=OVSIntPort
OVS_BRIDGE=br-ctlplane
OVS_OPTIONS="tag=10"
BOOTPROTO=static
IPADDR=10.0.0.1
PREFIX=24
NM_CONTROLLED=no
EOS

ifup vlan10
