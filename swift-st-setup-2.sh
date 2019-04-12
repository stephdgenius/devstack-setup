#!/bin/bash
clear

echo "Copying Swift Ring files from the Swift Proxy to all Storage Nodes"
sudo scp /etc/swift/*.gz 192.168.43.21:/etc/swift/
sudo scp /etc/swift/*.gz 192.168.43.22:/etc/swift/
echo "Task completed"