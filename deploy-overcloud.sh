#!/bin/bash

source ~/config
source stackrc

export DIB_YUM_REPO_CONF="/etc/yum.repos.d/delorean*"

openstack subnet set --dns-nameserver $DNS ctlplane-subnet

#curl -o overcloud-full.tar https://images.rdoproject.org/$VERSION/delorean/current-tripleo-rdo/overcloud-full.tar
#curl -o ironic-python-agent.tar https://images.rdoproject.org/$VERSION/delorean/current-tripleo-rdo/ironic-python-agent.tar
#mkdir ~/images
#tar -xpvf overcloud-full.tar -C ~/images/
#tar -xpvf ironic-python-agent.tar -C ~/images/
#openstack overcloud image upload --image-path ~/images/
openstack overcloud image build  		2>&1 | tee log-overcloud-image-build.txt
echo "openstack overcloud image build     result=${PIPESTATUS[0]}" >> result.txt
openstack overcloud image upload 		2>&1 | tee log-overcloud-image-upload.txt
echo "openstack overcloud image upload    result=${PIPESTATUS[0]}" >> result.txt

openstack overcloud node import instackenv.json	2>&1 | tee log-overcloud-node-import.txt
echo "openstack overcloud node import     result=${PIPESTATUS[0]}" >> result.txt
openstack overcloud node introspect --all-manageable 2>&1 | tee log-overcloud-node-instrospect.txt
echo "openstack overcloud node introspect result=${PIPESTATUS[0]}" >> result.txt
openstack overcloud node provide --all-manageable 2>&1 | tee log-overcloud-node-provide.txt
echo "openstack overcloud node provide    result=${PIPESTATUS[0]}" >> result.txt

#openstack overcloud deploy --templates --compute-scale 2 --ntp-server $NTP 2>&1 | tee log-overcloud-deploy.txt
#echo "openstack overcloud deploy          result=${PIPESTATUS[0]}" >> result.txt
cat << EOS > deploy-parameters.yaml
parameter_defaults:
  SwiftRingBuild: false
  RingBuild: false
EOS
openstack overcloud deploy --templates -e deploy-parameters.yaml --compute-scale 2 --ntp-server $NTP 2>&1 | tee log-overcloud-deploy.txt
echo "openstack overcloud deploy          result=${PIPESTATUS[0]}" >> result.txt
