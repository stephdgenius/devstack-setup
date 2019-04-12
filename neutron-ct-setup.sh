#!/bin/bash
clear

echo "Adding neutron user (set in service project)..."
openstack user create --domain default --project service --password myservicepassword neutron

echo "Adding neutron user in admin role..."
openstack role add --project service --user neutron admin

echo "Adding service entry for neutron..."
openstack service create --name neutron --description "OpenStack Networking service" network

echo "Adding endpoint for neutron (public)..."
openstack endpoint create --region RegionOne network public http://192.168.43.11:9696

echo "Adding endpoint for neutron (internal)..."
openstack endpoint create --region RegionOne network internal http://192.168.43.11:9696

echo "Adding endpoint for neutron (admin)..."
openstack endpoint create --region RegionOne network admin http://192.168.43.11:9696

echo "Adding a User and Database on MySQL for Neutron...."

NEUTRON_DBNAME="neutron"
NEUTRON_DBPASS="password"

# If /root/.my.cnf exists then it won't ask for root password
if [ -f /root/.my.cnf ]; then

    mysql -e "DROP DATABASE [IF EXISTS] ${NEUTRON_DBNAME};"
    mysql -e "CREATE DATABASE ${NEUTRON_DBNAME};"
    mysql -e "DROP USER [IF EXISTS] ${NEUTRON_DBNAME};"
    mysql -e "CREATE USER ${NEUTRON_DBNAME}@localhost IDENTIFIED BY '${NEUTRON_DBPASS}';"
    mysql -e "GRANT ALL PRIVILEGES ON ${NEUTRON_DBNAME}.* TO '${NEUTRON_DBNAME}'@'localhost' IDENTIFIED BY '$NEUTRON_DBPASS';"
    mysql -e "GRANT ALL PRIVILEGES ON ${NEUTRON_DBNAME}.* TO '${NEUTRON_DBNAME}'@'%' IDENTIFIED BY '$NEUTRON_DBPASS';"
    mysql -e "FLUSH PRIVILEGES;"

# If /root/.my.cnf doesn't exist then it'll ask for root password   
else
    echo "Please enter root user MySQL password!"
    read rootpasswd
    mysql -uroot -p${rootpasswd} -e "DROP DATABASE [IF EXISTS] ${NEUTRON_DBNAME};"
    mysql -uroot -p${rootpasswd} -e "CREATE DATABASE ${NEUTRON_DBNAME};"
    mysql -uroot -p${rootpasswd} -e "DROP USER [IF EXISTS] ${NEUTRON_DBNAME};"
    mysql -uroot -p${rootpasswd} -e "CREATE USER ${NEUTRON_DBNAME}@localhost IDENTIFIED BY '${NEUTRON_DBPASS}';"
    mysql -uroot -p${rootpasswd} -e "GRANT ALL PRIVILEGES ON ${NEUTRON_DBNAME}.* TO '${NEUTRON_DBNAME}'@'localhost' IDENTIFIED BY '$NEUTRON_DBPASS';"
    mysql -uroot -p${rootpasswd} -e "GRANT ALL PRIVILEGES ON ${NEUTRON_DBNAME}.* TO '${NEUTRON_DBNAME}'@'%' IDENTIFIED BY '$NEUTRON_DBPASS';"
    mysql -uroot -p${rootpasswd} -e "FLUSH PRIVILEGES;"
fi

echo "Installing Neutron..."
sudo apt -y install neutron-server neutron-metadata-agent neutron-plugin-ml2 python-neutronclient

echo "Configuring Neutron Server..."
sudo mv /etc/neutron/neutron.conf /etc/neutron/neutron.conf.org
sudo cp /devstack-setup/config/neutron/neutron-ct.conf /etc/neutron/neutron.conf
sudo cp /devstack-setup/config/neutron/metadata_agent.ini /etc/neutron/metadata_agent.ini
sudo cp /devstack-setup/config/neutron/ml2_conf.ini /etc/neutron/plugins/ml2/ml2_conf.ini

echo "Changing right access..."
sudo chmod 640 /etc/neutron/neutron.conf
sudo chgrp neutron /etc/neutron/neutron.conf

echo "Creating symbolic link..."
sudo ln -s /etc/neutron/plugins/ml2/ml2_conf.ini /etc/neutron/plugin.ini

echo "Running neutron-db-manage..."
sudo su -s /bin/bash neutron -c "neutron-db-manage --config-file /etc/neutron/neutron.conf --config-file /etc/neutron/plugin.ini upgrade head"

echo "Restarting Neutron..."
sudo systemctl restart neutron-server neutron-metadata-agent
sudo systemctl enable neutron-server neutron-metadata-agent
