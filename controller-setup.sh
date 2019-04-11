#!/bin/bash
clear
# Copie du fichier de configuration hosts
echo "Configuring domain name..."
sudo cp /devstack-setup/config/hosts /etc/hosts

# Téchargement de DevStack
echo "Downloading devstack..."
cd /
sudo git clone https://github.com/openstack-dev/devstack.git -b stable/rocky devstack/

# Copie du fichier de configuration de DevStack
sudo cp /devstack-setup/config/local.conf /devstack/local.conf

echo "Creating new user..."

# Creation d'un utilisateur pour l'environement de DevStack
sudo useradd -s /bin/bash -d /opt/stack -m stack

# Attribution des privilèges sudo a l'utilisateur précement crée
echo "stack ALL=(ALL) NOPASSWD: ALL" | sudo tee /etc/sudoers.d/stack

# Ajout de l'utilisateur au groupe sudo
sudo usermod -a -G sudo stack

# Creation du dossier Home pour le nouvel utilisateur
sudo usermod -d /home/stack