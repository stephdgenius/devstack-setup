#!/bin/bash
clear
echo "Installing devstack dependencies..."
# Installation des dépendances de DevStack
sudo apt -y install software-properties-common 
sudo add-apt-repository cloud-archive:rocky
sudo add-apt-repository universe
sudo apt update
sudo apt -y upgrade 
sudo apt-get install graphviz -y
sudo apt-get install python-systemd

echo "Changing access rights to the devstack folder..."
chown -R stack /devstack
chmod 770 /devstack

echo "Launching devstack setup..."
cd /devstack
./stack.sh