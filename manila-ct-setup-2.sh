echo "Installing Manila services..."
sudo apt -y install manila-api manila-scheduler python-manilaclient

echo "Configuring Manila..."
mv /etc/manila/manila.conf /etc/manila/manila.conf.org
cp /devstack-setup/config/manila/manila-ct.conf /etc/manila/manila.conf

echo "Changing right access..."
chmod 644 /etc/manila/manila.conf 
chown manila. /etc/manila/manila.conf

echo "Running manila-manage db..."
su -s /bin/bash manila -c "manila-manage db sync"

echo "Restarting Manila..."
systemctl restart manila-api manila-scheduler 
systemctl enable manila-api manila-scheduler