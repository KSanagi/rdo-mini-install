#!/bin/bash

source openshiftrc

PROJECT_ID=`openstack project show $OS_PROJECT_NAME -c id -f value`
openstack server list -c ID -f value | xargs openstack server delete
neutron purge $PROJECT_ID
openstack project purge --keep-project --project $PROJECT_ID
OCUSER=$OS_USERNAME

source overcloudrc

openstack project delete $PROJECT_ID
openstack user delete $OCUSER
