#!/bin/bash -eux

# Have this reviewed by Pro's - what packages are really required?

# ruby and wget for opsworks and vagrant - cant install within packages with minimal iso
yum -y -q groupinstall "Development Tools" 
yum -y install ruby wget

# some package we will need for vagrant and guest addition
yum -y install yum-priorities
yum -y install epel-release
wget -r --no-parent -A 'epel-release-*.rpm' http://dl.fedoraproject.org/pub/epel/7/x86_64/e/ 
rpm -Uvh dl.fedoraproject.org/pub/epel/7/x86_64/e/epel-release-*.rpm
yum -y install gcc gcc-c++ bzip2 make perl
yum -y install kernel-devel kernel-headers dkms kernel-devel-$(uname -r) kernel-headers-$(uname -r)

if [ -f /home/vagrant/.vbox_version ]; then
    echo "==> Installing VirtualBox guest additions"

    VBOX_VERSION=$(cat /home/vagrant/.vbox_version)
	VBOX_ISO=/home/vagrant/VBoxGuestAdditions_$VBOX_VERSION.iso
	cd /tmp
	
	if [ ! -f $VBOX_ISO ] ; then
		wget -q http://download.virtualbox.org/virtualbox/${VBOX_VERSION}/VBoxGuestAdditions_${VBOX_VERSION}.iso \
			-O $VBOX_ISO
	fi

    mount -o loop $VBOX_ISO /mnt
    sh /mnt/VBoxLinuxAdditions.run
    umount /mnt

    rm $VBOX_ISO
    rm /home/vagrant/.vbox_version

    if [[ $VBOX_VERSION = "4.3.10" ]]; then
        ln -s /opt/VBoxGuestAdditions-4.3.10/lib/VBoxGuestAdditions /usr/lib/VBoxGuestAdditions
    fi
fi

if [ -f /home/vagrant/vmware_tools.iso ]; then
    echo "==> Installing VMware Tools"
    # Assuming the following packages are installed
    # yum install -y linux-headers-$(uname -r) build-essential perl

    cd /tmp
    mkdir -p /mnt/cdrom
    mount -o loop /home/vagrant/vmware_tools.iso /mnt/cdrom
    tar zxf /mnt/cdrom/VMwareTools-*.tar.gz -C /tmp/

    /tmp/vmware-tools-distrib/vmware-install.pl -d

    rm /home/vagrant/vmware_tools.iso
    umount /mnt/cdrom
    rmdir /mnt/cdrom
    rm -rf /tmp/VMwareTools-*
fi

yum remove kernel-devel-$(uname -r)
yum clean all
