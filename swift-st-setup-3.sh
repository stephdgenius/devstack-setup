#!/bin/bash
clear

echo "Changing right access..."
chown swift. /etc/swift/*.gz 

echo "Configuring Swift and Rsync in Storage Node..."
sudo cp /devstack-setup/config/swift/swift.conf /etc/swift/swift.conf
sudo cp /devstack-setup/config/swift/account-server.conf /etc/swift/account-server.conf
sudo cp /devstack-setup/config/swift/container-server.conf /etc/swift/container-server.conf
sudo cp /devstack-setup/config/swift/object-server.conf /etc/swift/object-server.conf
sudo cp /devstack-setup/config/swift/rsyncd.conf /etc/rsyncd.conf

echo "Enable Rsync..."
sudo nano /etc/default/rsync

echo "Launching Swift..."
systemctl start rsync
systemctl enable rsync 
for ringtype in account container object; do 
    systemctl start swift-$ringtype
    systemctl enable swift-$ringtype
    for service in replicator updater auditor; do
        if [ $ringtype != 'account' ] || [ $service != 'updater' ]; then
            systemctl start swift-$ringtype-$service
            systemctl enable swift-$ringtype-$service
        fi
    done
done