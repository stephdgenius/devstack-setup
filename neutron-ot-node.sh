#!/bin/bash
clear

echo "Installing required packages for this node..."
sudo apt -y install neutron-common neutron-plugin-ml2 neutron-linuxbridge-agent

echo "Configuring neutron on this node..."
sudo mv /etc/neutron/neutron.conf /etc/neutron/neutron.conf.org
sudo cp /devstack-setup/config/neutron/neutron-nt.conf /etc/neutron/neutron.conf
sudo cp /devstack-setup/config/neutron/ml2_conf.ini /etc/neutron/plugins/ml2/ml2_conf.ini
sudo cp /devstack-setup/config/neutron/linuxbridge_agent-ot.ini /etc/neutron/plugins/ml2/linuxbridge_agent.ini

echo "Creating symbolic link..."
sudo ln -s /etc/neutron/plugins/ml2/ml2_conf.ini /etc/neutron/plugin.ini

echo "Restarting Neutron..."
sudo systemctl restart nova-compute neutron-linuxbridge-agent 
sudo systemctl enable neutron-linuxbridge-agent