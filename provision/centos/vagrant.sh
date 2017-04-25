#!/bin/bash -eux

# https://raw.githubusercontent.com/mitchellh/vagrant/master/keys/vagrant.pub
VAGRANT_INSECURE_KEY="ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA6NF8iallvQVp22WDkTkyrtvp9eWW6A8YVr+kz4TjGYe7gHzIw+niNltGEFHzD8+v1I2YJ6oXevct1YeS0o9HZyN1Q9qgCgzUFtdOKLv6IedplqoPkcmF0aYet2PkEDo3MlTBckFXPITAMzF8dJSIFo9D8HfdOV0IAdx4O7PtixWKn5y2hMNG0zQPyUecp4pzC6kivAIhyfHilFR61RGL+GPXQ2MWZWFYbAGjyiYJnAmCP3NOTd0jMZEnDkbUvxhMmBYSdETk1rRgm+R4LOzFUGaHqHDLKLX+FIPKcF96hrucXzcWyLbIbEgE98OHlnVYCzRdK8jlqm8tehUc9c9WhQ== vagrant insecure public key"

# Store build time
date > /etc/vagrant_box_build_time

# Create Vagrant user (if not already present)
if ! id -u vagrant >/dev/null 2>&1; then
    echo "==> Creating vagrant user"
    /usr/sbin/groupadd vagrant
    /usr/sbin/useradd vagrant -g vagrant -G wheel -d /home/vagrant --create-home
    echo "vagrant:vagrant" | chpasswd
fi

# @TODO: That happend already in kickstart ks.cfg ?! which one is best to keep?
if [ ! -f /etc/sudoers.d/wheel ]; then
	echo "==> Giving vagrant sudo powers"
	/bin/cat >> /etc/sudoers.d/wheel << EOF_sudoers_wheel
Defaults:%wheel		env_keep += "SSH_AUTH_SOCK"
Defaults:%wheel		!requiretty
%wheel	ALL=(ALL)	ALL
%wheel	ALL=(ALL)	NOPASSWD: ALL
EOF_sudoers_wheel
fi

echo "==> Installing vagrant key"
mkdir -p /home/vagrant/.ssh
chmod 700 /home/vagrant/.ssh
echo "${VAGRANT_INSECURE_KEY}" > /home/vagrant/.ssh/authorized_keys
chmod 600 /home/vagrant/.ssh/authorized_keys
chown -R vagrant:vagrant /home/vagrant/.ssh

# Remove those annoying "stdin: is not a tty" messages when running vagrant
#sed -i "s/mesg n/tty -s \&\& mesg n/g" /root/.profile
