#!/bin/bash

source config

VM=$1
MAC=$2
MAC2=$3
CPU="4"
MEM=$4
PUBKEYS=`cat /root/.ssh/id_rsa.pub`
ISO="/var/www/html/iso/CentOS-7-x86_64-DVD-1908.iso"

cat << __EOS__ > /tmp/$VM-ks.cfg
auth --enableshadow --passalgo=sha512
install
cdrom
text
cmdline
skipx

firstboot --disabled
ignoredisk --only-use=vda
keyboard --vckeymap=us --xlayouts='us'
lang en_US.UTF-8

network --activate --bootproto=dhcp --noipv6 --hostname=$VM
 
services --enabled="chronyd"
timezone America/New_York --isUtc

rootpw --plaintext rootroot
bootloader --append=" crashkernel=auto" --location=mbr --boot-drive=vda
autopart --type=lvm
clearpart --none --initlabel

reboot

%post --logfile /dev/console
mkdir -p /root/.ssh
restorecon -R /root/.ssh
chmod 600 /root/.ssh/id_rsa
cat >>/root/.ssh/authorized_keys <<"__EOF__"
$PUBKEYS
__EOF__
chmod go-w /root /root/.ssh /root/.ssh/authorized_keys
echo "Host *" > /root/.ssh/config
echo "  StrictHostKeyChecking no" >> /root/.ssh/config
echo "  UserKnownHostsFile=/dev/null" >> /root/.ssh/config
chmod 600 /root/.ssh/config
%end

%packages
@^minimal
@core
chrony
kexec-tools

%end

%addon com_redhat_kdump --enable --reserve-mb='auto'

%end

%anaconda
pwpolicy root --minlen=6 --minquality=1 --notstrict --nochanges --notempty
pwpolicy user --minlen=6 --minquality=1 --notstrict --nochanges --emptyok
pwpolicy luks --minlen=6 --minquality=1 --notstrict --nochanges --notempty
%end
__EOS__

virt-install \
 --name $VM \
 --hvm \
 --virt-type kvm \
 --ram $MEM \
 --vcpus $CPU \
 --cpu host-passthrough \
 --arch x86_64 \
 --os-type linux \
 --os-variant rhel7 \
 --boot hd \
 --disk pool=default,size=50,format=qcow2 \
 --network network=$NET,mac=$MAC \
 --network network=$NET2,mac=$MAC2 \
 --graphics vnc \
 --serial pty \
 --console pty \
 --noautoconsole \
 --wait=-1 \
 --location $ISO \
 --initrd-inject /tmp/$VM-ks.cfg \
 --extra-args "inst.ks=file:/$VM-ks.cfg console=ttyS0"

rm -f /tmp/$VM-ks.cfg
