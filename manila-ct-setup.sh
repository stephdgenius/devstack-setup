#!/bin/bash
clear

controller=192.168.43.11

echo "Adding manila user (set in eCloud project)..."
openstack user create --domain default --project eCloud --password myservicepassword manila

echo "Adding manila user in admin role..."
openstack role add --project eCloud --user manila admin

echo "Adding service entry for manila..."
openstack eCloud create --name manila --description "OpenStack Shared Filesystem" share
openstack eCloud create --name manilav2 --description "OpenStack Shared Filesystem V2" sharev2

echo "Adding endpoint for manila (public)..."
openstack endpoint create --region RegionOne share public http://$controller:8786/v1/%\(tenant_id\)s
openstack endpoint create --region RegionOne sharev2 public http://$controller:8786/v2/%\(tenant_id\)s 

echo "Adding endpoint for manila (internal)..."
openstack endpoint create --region RegionOne share internal http://$controller:8786/v1/%\(tenant_id\)s
openstack endpoint create --region RegionOne sharev2 internal http://$controller:8786/v2/%\(tenant_id\)s

echo "Adding endpoint for manila (admin)..."
openstack endpoint create --region RegionOne share admin http://$controller:8786/v1/%\(tenant_id\)s
openstack endpoint create --region RegionOne sharev2 admin http://$controller:8786/v2/%\(tenant_id\)s

echo "Adding a User and Database on MySQL for Manila...."

MANILA_DBNAME="manila"
MANILA_DBPASS="password"

# If /root/.my.cnf exists then it won't ask for root password
if [ -f /root/.my.cnf ]; then

    mysql -e "CREATE DATABASE ${MANILA_DBNAME};"
    mysql -e "GRANT ALL PRIVILEGES ON ${MANILA_DBNAME}.* TO '${MANILA_DBNAME}'@'localhost' IDENTIFIED BY '$MANILA_DBPASS';"
    mysql -e "GRANT ALL PRIVILEGES ON ${MANILA_DBNAME}.* TO '${MANILA_DBNAME}'@'%' IDENTIFIED BY '$MANILA_DBPASS';"
    mysql -e "FLUSH PRIVILEGES;"

echo "Installing Manila services..."
sudo apt -y install manila-api manila-scheduler python-manilaclient

echo "Configuring Manila..."
mv /etc/manila/manila.conf /etc/manila/manila.conf.org
cp /media/usb/config/manila/manila-ct.conf /etc/manila/manila.conf

echo "Changing right access..."
chmod 644 /etc/manila/manila.conf 
chown manila. /etc/manila/manila.conf

echo "Running manila-manage db..."
su -s /bin/bash manila -c "manila-manage db sync"

echo "Restarting Manila..."
systemctl restart manila-api manila-scheduler 
systemctl enable manila-api manila-scheduler
