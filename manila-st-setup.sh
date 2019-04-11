#!/bin/bash
clear

echo "Installing Manila Share..."
apt -y install manila-share python-pymysql

echo "Configuring Manila..."
mv /etc/manila/manila.conf /etc/manila/manila.conf.org
cp /media/usb/config/manila/manila-st.conf /etc/manila/manila.conf

echo "Changing right access..."
chmod 644 /etc/manila/manila.conf 
chown manila. /etc/manila/manila.conf 