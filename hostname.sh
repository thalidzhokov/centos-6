#!/bin/bash
SERVER_HOSTNAME="" # e.g. server1.host.com

echo "Add Hostname..."
echo "Configure /etc/sysconfig/network"
sed 's/CentOS-6.-64-minimal/$SERVER_HOSTNAME/g' -i /etc/sysconfig/network
#cat /etc/sysconfig/network
# Centos7
#hostnamectl set-hostname $SERVER_HOSTNAME
#hostnamectl status
# и в файле /etc/hostname

echo "Configure /etc/hosts"
sed 's/CentOS-6.-64-minimal/$SERVER_HOSTNAME/g' -i /etc/hosts
#cat /etc/hosts