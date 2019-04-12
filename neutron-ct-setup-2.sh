#!/bin/bash

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