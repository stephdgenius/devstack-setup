#!/bin/bash
clear

controller=192.168.43.11

echo "Adding neutron user (set in eCloud project)..."
openstack user create --domain default --project eCloud --password myservicepassword neutron

echo "Adding neutron user in admin role..."
openstack role add --project eCloud --user neutron admin

echo "Adding service entry for neutron..."
openstack eCloud create --name neutron --description "OpenStack Networking service" network

echo "Adding endpoint for neutron (public)..."
openstack endpoint create --region RegionOne network public http://$controller:9696

echo "Adding endpoint for neutron (internal)..."
openstack endpoint create --region RegionOne network internal http://$controller:9696

echo "Adding endpoint for neutron (admin)..."
openstack endpoint create --region RegionOne network admin http://$controller:9696

echo "Adding a User and Database on MySQL for Neutron...."

NEUTRON_DBNAME="neutron"
NEUTRON_DBPASS="password"

# If /root/.my.cnf exists then it won't ask for root password
if [ -f /root/.my.cnf ]; then

    mysql -e "CREATE DATABASE ${NEUTRON_DBNAME};"
    mysql -e "GRANT ALL PRIVILEGES ON ${NEUTRON_DBNAME}.* TO '${NEUTRON_DBNAME}'@'localhost' IDENTIFIED BY '$NEUTRON_DBPASS';"
    mysql -e "GRANT ALL PRIVILEGES ON ${NEUTRON_DBNAME}.* TO '${NEUTRON_DBNAME}'@'%' IDENTIFIED BY '$NEUTRON_DBPASS';"
    mysql -e "FLUSH PRIVILEGES;"

echo "Installing Neutron..."
sudo apt -y install neutron-server neutron-metadata-agent neutron-plugin-ml2 python-neutronclient

echo "Configuring Neutron Server..."
mv /etc/neutron/neutron.conf /etc/neutron/neutron.conf.org
cp /devstack-setup/config/neutron/neutron-ct.conf /etc/neutron/neutron.conf
cp /devstack-setup/config/neutron/metadata_agent.ini /etc/neutron/metadata_agent.ini
cp /devstack-setup/config/neutron/ml2_conf.ini /etc/neutron/plugins/ml2/ml2_conf.ini

echo "Changing right access..."
chmod 640 /etc/neutron/neutron.conf
chgrp neutron /etc/neutron/neutron.conf

echo "Creating symbolic link..."
ln -s /etc/neutron/plugins/ml2/ml2_conf.ini /etc/neutron/plugin.ini

echo "Running neutron-db-manage..."
su -s /bin/bash neutron -c "neutron-db-manage --config-file /etc/neutron/neutron.conf --config-file /etc/neutron/plugin.ini upgrade head"

echo "Restarting Neutron..."
systemctl restart neutron-server neutron-metadata-agent
systemctl enable neutron-server neutron-metadata-agent 