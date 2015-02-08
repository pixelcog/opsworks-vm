#!/bin/bash -eux

echo "==> Updating packages"

sudo find /var/lib/apt/lists -type f -exec rm -v {} \;
apt-get -y update
apt-get -y upgrade