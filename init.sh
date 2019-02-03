#!/bin/bash

source /root/config

sudo useradd stack
echo "stack ALL=(root) NOPASSWD:ALL" | sudo tee -a /etc/sudoers.d/stack
sudo chmod 0440 /etc/sudoers.d/stack

mkdir /home/stack/.ssh
cp /root/.ssh/* /home/stack/.ssh
chown -R stack.stack /home/stack/.ssh
chmod 755 /home/stack/.ssh
chmod 600 /home/stack/.ssh/*

rpmname=`curl -s https://trunk.rdoproject.org/centos7/current/ | grep python2-tripleo-repos | sed -r 's/.*(python2-.*rpm).*/\1/'`
yum install -y https://trunk.rdoproject.org/centos7/current/$rpmname
sudo -E tripleo-repos -b $VERSION current
#yum -y install epel-release
#yum -y install centos-release-openstack-$VERSION
yum install -y python-tripleoclient

cp /usr/share/instack-undercloud/undercloud.conf.sample /home/stack/undercloud.conf
#cp /usr/share/python-tripleoclient/undercloud.conf.sample /home/stack/undercloud.conf
sed -i -e "1a undercloud_ntp_servers = $NTP" /home/stack/undercloud.conf
sed -i -e "1a undercloud_nameservers = $DNS" /home/stack/undercloud.conf
chown stack.stack /home/stack/undercloud.conf

yum update -y
reboot
