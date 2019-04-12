#!/bin/bash
clear

echo "Adding neutron user (set in service project)..."
openstack user create --domain default --project service --password myservicepassword neutron

echo "Adding neutron user in admin role..."
openstack role add --project service --user neutron admin

echo "Adding service entry for neutron..."
openstack service create --name neutron --description "OpenStack Networking service" network

echo "Adding endpoint for neutron (public)..."
openstack endpoint create --region RegionOne network public http://192.168.43.11:9696

echo "Adding endpoint for neutron (internal)..."
openstack endpoint create --region RegionOne network internal http://192.168.43.11:9696

echo "Adding endpoint for neutron (admin)..."
openstack endpoint create --region RegionOne network admin http://192.168.43.11:9696
