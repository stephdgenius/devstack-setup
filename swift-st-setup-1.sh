#!/bin/bash
clear

echo "Installing Swift on Storage node..."
sudo apt -y install swift swift-account swift-container swift-object xfsprogs

echo "Formating free space of disk with XFS and mount on srv/node..."
sudo mkfs.xfs -i size=1024 -s size=4096 /dev/sdb
mkdir -p /srv/node/device0
mount -o noatime,nodiratime,nobarrier /dev/sdb /srv/node/device0
chown -R swift. /srv/node
sudo cp /media/usb/config/swift/fstab /etc/fstab
sudo nano /etc/fstab