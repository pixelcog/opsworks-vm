#!/bin/bash -eux

# Make sure udev does not block our network
echo "==> Cleaning up udev rules"
rm /etc/udev/rules.d/70-persistent-ipoib.rules

if [ -d "/var/lib/dhclient" ]; then
    echo "==> Cleaning up leftover dhcp leases"
    dhclient -r
	rm /var/lib/dhclient/*
fi

# Disable DNS reverse lookup
echo "UseDNS no" >> /etc/ssh/sshd_config
