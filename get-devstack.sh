#!/bin/bash
clear

# Téchargement de DevStack
echo "Downloading devstack..."
cd /
sudo git clone https://github.com/openstack-dev/devstack.git -b stable/rocky devstack/

# Copie du fichier de configuration de DevStack
sudo cp /devstack-setup/config/local.conf /devstack/local.conf