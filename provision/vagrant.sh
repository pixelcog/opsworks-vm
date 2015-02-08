#!/bin/bash -eux

# https://raw.githubusercontent.com/mitchellh/vagrant/master/keys/vagrant.pub
VAGRANT_INSECURE_KEY="ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA6NF8iallvQVp22WDkTkyrtvp9eWW6A8YVr+kz4TjGYe7gHzIw+niNltGEFHzD8+v1I2YJ6oXevct1YeS0o9HZyN1Q9qgCgzUFtdOKLv6IedplqoPkcmF0aYet2PkEDo3MlTBckFXPITAMzF8dJSIFo9D8HfdOV0IAdx4O7PtixWKn5y2hMNG0zQPyUecp4pzC6kivAIhyfHilFR61RGL+GPXQ2MWZWFYbAGjyiYJnAmCP3NOTd0jMZEnDkbUvxhMmBYSdETk1rRgm+R4LOzFUGaHqHDLKLX+FIPKcF96hrucXzcWyLbIbEgE98OHlnVYCzRdK8jlqm8tehUc9c9WhQ== vagrant insecure public key"

# Store build time
date > /etc/vagrant_box_build_time

# Create Vagrant user (if not already present)
if ! id -u vagrant >/dev/null 2>&1; then
    echo "==> Creating vagrant user"
    /usr/sbin/groupadd vagrant
    /usr/sbin/useradd vagrant -g vagrant -G sudo -d /home/vagrant --create-home
    echo "vagrant:vagrant" | chpasswd
fi

echo "==> Giving vagrant sudo powers"
echo "vagrant        ALL=(ALL)       NOPASSWD: ALL" >> /etc/sudoers

echo "==> Installing vagrant key"
mkdir -p /home/vagrant/.ssh
chmod 700 /home/vagrant/.ssh
echo "${VAGRANT_INSECURE_KEY}" > /home/vagrant/.ssh/authorized_keys
chmod 600 /home/vagrant/.ssh/authorized_keys
chown -R vagrant:vagrant /home/vagrant/.ssh

# Remove those annoying "stdin: is not a tty" messages when running vagrant
sed -i "s/mesg n/tty -s \&\& mesg n/g" /root/.profile