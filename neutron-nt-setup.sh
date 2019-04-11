#!/bin/bash
clear

echo "Installing required packages for Network Node..."
sudo apt -y install neutron-plugin-ml2 neutron-linuxbridge-agent neutron-l3-agent neutron-dhcp-agent neutron-metadata-agent python-neutronclient

echo "Configuring as a Network node..."
sudo mv /etc/neutron/neutron.conf /etc/neutron/neutron.conf.org
sudo cp /devstack-setup/config/neutron/neutron-ct.conf /etc/neutron/neutron.conf
sudo cp /devstack-setup/config/neutron/l3_agent.ini /etc/neutron/l3_agent.ini
sudo cp /devstack-setup/config/neutron/dhcp_agent.ini /etc/neutron/dhcp_agent.ini
sudo cp /devstack-setup/config/neutron/metadata_agent.ini /etc/neutron/metadata_agent.ini
sudo cp /devstack-setup/config/neutron/ml2_conf.ini /etc/neutron/plugins/ml2/ml2_conf.ini
sudo cp /devstack-setup/config/neutron/linuxbridge_agent-nt.ini /etc/neutron/plugins/ml2/linuxbridge_agent.ini

echo "Changing right access..."
sudo chmod 640 /etc/neutron/neutron.conf
sudo chgrp neutron /etc/neutron/neutron.conf

echo "Creating symbolic link..."
sudo ln -s /etc/neutron/plugins/ml2/ml2_conf.ini /etc/neutron/plugin.ini 

echo "Restarting Neutron..."
for service in l3-agent dhcp-agent metadata-agent linuxbridge-agent; do
sudo systemctl restart neutron-$service
sudo systemctl enable neutron-$service
done