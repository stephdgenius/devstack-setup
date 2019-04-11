#!/bin/bash
clear

# Téchargement de DevStack
echo "Downloading devstack..."
cd /
sudo git clone https://git.openstack.org/openstack-dev/devstack

# Copie du fichier de configuration de DevStack
sudo cp /devstack-setup/config/local.conf /devstack/local.conf