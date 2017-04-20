#!/bin/bash
# WARNING! This script only for CentOS 6

#####

# Timezone
if rpm -qa | grep tzdata; then
  echo "tzdata installed... update tzdata..."
  yum update tzdata -y
else
  echo "tzdata not installed... install tzdata..."
  yum install tzdata -y
fi

# Set Europe/Moscow timezone
yes | cp /etc/localtime /tmp/old.localetime -f
rm /etc/localtime -f
ln -s /usr/share/zoneinfo/Europe/Moscow /etc/localtime

# Check timezone
#date
#ls -l /etc/localtime

#####

# Locale
echo "Check availability ru_RU locale..."

if locale -a | grep ru_RU; then
  echo "Set locale ru_RU.UTF-8..."
  sed -e 's/LANG=.*$/LANG="ru_RU.UTF-8"/g' -i /etc/sysconfig/i18n # Debian /etc/default/locale   Centos7 /etc/locale.conf
else
  echo "Locale ru_RU.UTF-8 not available..."
fi

# Check locale
#cat /etc/sysconfig/i18n
#locale

#####

# NTP
if rpm -qa | grep ntp; then
  echo "ntp installed... update ntp..."
  yum update ntp -y
  service ntpd restart
else
  echo "ntp not installed... install ntp..."
  yum install ntp -y
  service ntpd start
fi

# Enable NTP service
chkconfig ntpd on # Centos7 systemctl enable ntpd.service

# Check peers
#ntpq -c peers

# WARNING! Add iptables rule
#iptables -A OUTPUT -o eth0 -p udp --sport 123 --dport 123 -j ACCEPT

#####
