#!/bin/bash -eux

echo "==> Updating packages"

# required for later cleanup and minimize
yum -y -q install yum-utils

yum -y update
yum -y upgrade