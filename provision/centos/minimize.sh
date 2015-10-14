#!/bin/bash -eux

###############################
# @TODO: adopt this to CentOS 7
###############################

echo "==> Installed packages before cleanup"
rpm -qa | less

# Remove some packages to get a minimal install
#echo "==> Removing all linux kernels except the currrent one"
#dpkg --list | awk '{ print $2 }' | grep 'linux-image-3.*-generic' | grep -v $(uname -r) | xargs apt-get -y purge
#echo "==> Removing linux source"
#dpkg --list | awk '{ print $2 }' | grep linux-source | xargs apt-get -y purge
# echo "==> Removing development packages"
# dpkg --list | awk '{ print $2 }' | grep -- '-dev$' | xargs apt-get -y purge
#echo "==> Removing documentation"
#dpkg --list | awk '{ print $2 }' | grep -- '-doc$' | xargs apt-get -y purge
#echo "==> Removing X11 libraries"
#apt-get -y purge libx11-data xauth libxmuu1 libxcb1 libx11-6 libxext6
#echo "==> Removing obsolete networking components"
#apt-get -y purge ppp pppconfig pppoeconf
#echo "==> Removing other oddities"
#apt-get -y purge popularity-contest installation-report landscape-common wireless-tools wpasupplicant ubuntu-serverguide

# Clean up the yum cache
yum clean all

# Clean up orphaned packages with yum utils' package-cleanup
package-cleanup --quiet --leaves

# echo "==> Removing man pages"
# rm -rf /usr/share/man/*
# echo "==> Removing APT files"
# find /var/lib/apt -type f | xargs rm -f
echo "==> Removing anything in /usr/src"
rm -rf /usr/src/*
echo "==> Removing any docs"
rm -rf /usr/share/doc/*
echo "==> Removing caches"
find /var/cache -type f -exec rm -rf {} \;
