#!/bin/bash
clear

echo "Adding swift user (set in service project)..."
openstack user create --domain default --project service --password myservicepassword swift

echo "Adding swift user in admin role..."
openstack role add --project service --user swift admin

echo "Adding service entry for swift..."
openstack service create --name swift --description "OpenStack Object Storage" object-store

echo "Adding endpoint for swift (public)..."
openstack endpoint create --region RegionOne object-store public http://192.168.43.11:8080/v1/AUTH_%\(tenant_id\)s 

echo "Adding endpoint for swift (internal)..."
openstack endpoint create --region RegionOne object-store internal http://192.168.43.11:8080/v1/AUTH_%\(tenant_id\)s

echo "Adding endpoint for swift (admin)..."
openstack endpoint create --region RegionOne object-store admin http://192.168.43.11:8080/v1

echo "Installing Swift Proxy..."
sudo apt -y install swift swift-proxy python-swiftclient python-keystonemiddleware python-memcache

echo "Configuring Swift Proxy..."
sudo mkdir /etc/swift 
sudo cp /devstack-setup/config/swift/proxy-server.conf /etc/swift/proxy-server.conf
sudo cp /devstack-setup/config/swift/swift.conf /etc/swift/swift.conf

echo "Changing right access..."
chown -R swift. /etc/swift

echo "Configuring Swift Ring files..."
cd /etc/swift
sudo rm -f account.builder account.ring.gz backups/account.builder backups/account.ring.gz
sudo rm -f container.builder container.ring.gz backups/container.builder backups/container.ring.gz
sudo rm -f object.builder object.ring.gz backups/object.builder backups/object.ring.gz
sudo swift-ring-builder account.builder create 12 3 1
sudo swift-ring-builder container.builder create 12 3 1
sudo swift-ring-builder object.builder create 12 3 1

sudo swift-ring-builder account.builder add r0z0-192.168.43.21:6002/device0 100
sudo swift-ring-builder container.builder add r0z0-192.168.43.21:6001/device0 100
sudo swift-ring-builder object.builder add r0z0-192.168.43.21:6000/device0 100

sudo swift-ring-builder account.builder add r1z1-192.168.43.22:6002/device1 100
sudo swift-ring-builder container.builder add r1z1-192.168.43.22:6001/device1 100
sudo swift-ring-builder object.builder add r1z1-192.168.43.22:6000/device1 100

sudo swift-ring-builder account.builder rebalance
sudo swift-ring-builder container.builder rebalance
sudo swift-ring-builder object.builder rebalance

cd /devstack-setup

echo "Changing right access..."
sudo chown swift. /etc/swift/*.gz
sudo systemctl restart swift-proxy