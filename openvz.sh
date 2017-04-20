#!/bin/bash
# Install and configure OpenVZ


echo "Install OpenVZ..."
echo "repo"
wget -P /etc/yum.repos.d/ https://download.openvz.org/openvz.repo
echo "key"
rpm --import http://download.openvz.org/RPM-GPG-Key-OpenVZ
echo "install"
yum install  \
    vzkernel \
    vzctl    \
    vzquota  \
    ploop    \
    -y

echo "Download templates..."
vztmpl-dl                   \
    centos-6-x86_64-minimal \
    centos-7-x86_64-minimal

echo "Add /etc/sysconfig/vz-scripts/ve-default.conf-sample ..."
# /etc/sysconfig/vz-scripts/ve-openvz-v1.conf-sample
cat > /etc/sysconfig/vz-scripts/ve-default.conf-sample <<- DEFAULT
ONBOOT="yes"

# CPU
CPUUNITS="1000"
CPUS="2"
CPULIMIT="50"

# RAM
PHYSPAGES="0:2G"
SWAPPAGES="0:4G"

# DISK
DISKSPACE="29G:30G"
DISKINODES="2900000:3000000"
QUOTAUGIDLIMIT="1000"
QUOTATIME="0"

# OTHER
KMEMSIZE="unlimited"
LOCKEDPAGES="unlimited"
SHMPAGES="unlimited"
NUMPROC="unlimited"
VMGUARPAGES="unlimited"
OOMGUARPAGES="unlimited"
NUMTCPSOCK="unlimited"
NUMFLOCK="unlimited"
NUMPTY="unlimited"
NUMSIGINFO="unlimited"
TCPSNDBUF="unlimited"
TCPRCVBUF="unlimited"
OTHERSOCKBUF="unlimited"
DGRAMRCVBUF="unlimited"
NUMOTHERSOCK="unlimited"
DCACHESIZE="unlimited"
NUMFILE="unlimited"
AVNUMPROC="unlimited"
NUMIPTENT="unlimited"

# VE
VE_ROOT="/vz/root/\$VEID"
VE_PRIVATE="/vz/private/\$VEID"
VE_LAYOUT="simfs"
DEFAULT

echo "Configure /etc/vz/vz.conf ..."
sed \
    -e 's/CONFIGFILE=".*"$/CONFIGFILE="default"/g' \
    -e 's/DEF_OSTEMPLATE=".*"$/DEF_OSTEMPLATE="centos-6-x86_64-minimal"/g' \
    -e 's/VE_LAYOUT=.*$/VE_LAYOUT=simfs/g' \
    -i /etc/vz/vz.conf

# /etc/vz/vz.conf
# IP6TABLES="ip6_tables ip6table_filter ip6table_mangle ip6t_REJECT nf_conntrack_ipv6"
if cat /etc/vz/vz.conf | grep "IP6TABLES="; then
    echo "IP6TABLES isset... set to 'ip6_tables ip6table_filter ip6table_mangle ip6t_REJECT nf_conntrack_ipv6'"
    sed \
        -e 's/IP6TABLES=.*/IP6TABLES="ip6_tables ip6table_filter ip6table_mangle ip6t_REJECT nf_conntrack_ipv6"/g' \
        -i /etc/vz/vz.conf
else
    echo "IP6TABLES not set... add IP6TABLES"
    echo 'IP6TABLES="ip6_tables ip6table_filter ip6table_mangle ip6t_REJECT nf_conntrack_ipv6"' >> /etc/vz/vz.conf
fi

# /etc/sysctl.conf
# net.ipv6.conf.default.forwarding=1
# net.ipv6.conf.all.forwarding=1
# net.ipv6.conf.all.proxy_ndp=1
SYSCTL_IPV6_CONFIGS="net.ipv6.conf.default.forwarding net.ipv6.conf.all.forwarding net.ipv6.conf.all.proxy_ndp"

for SYSCTL_IPV6_CONFIG in $SYSCTL_IPV6_CONFIGS
do
    if cat /etc/sysctl.conf | grep "$SYSCTL_IPV6_CONFIG="; then
        echo "$SYSCTL_IPV6_CONFIG isset... set to 1"
        sed \
            -e "s/$SYSCTL_IPV6_CONFIG=.*/$SYSCTL_IPV6_CONFIG=1/g" \
            -i /etc/sysctl.conf
    else
        echo "$SYSCTL_IPV6_CONFIG not set... add $SYSCTL_IPV6_CONFIG"
        echo "$SYSCTL_IPV6_CONFIG=1" >> /etc/sysctl.conf
    fi
done

echo "Reboot..."
reboot

