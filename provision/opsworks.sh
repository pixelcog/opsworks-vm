#!/bin/bash -eux

# set the agent version to be installed
AGENT_VERSION="3432-20160120135248"

echo "==> Generating chef json for first OpsWorks run"
TMPDIR=$(mktemp -d) && trap 'rm -rf "$TMPDIR"' EXIT
mkdir -p $TMPDIR/cookbooks

# Create a base json file to execute some default recipes
cat <<EOT > $TMPDIR/dna.json
{
  "opsworks_initial_setup": {
    "swapfile_instancetypes": null
  },
  "opsworks_custom_cookbooks": {
    "enabled": true,
    "scm": {
      "repository": "$TMPDIR/cookbooks"
    },
    "manage_berkshelf": true,
    "recipes": [
      "recipe[opsworks_initial_setup]",
      "recipe[ssh_host_keys]",
      "recipe[ssh_users]",
      "recipe[dependencies]",
      "recipe[apt]",
      "recipe[deploy::default]",
      "recipe[agent_version]",
      "recipe[opsworks_stack_state_sync]",
      "recipe[opsworks_cleanup]"
    ]
  }
}
EOT

# Use Berkshelf to pre-load some commonly-used community cookbooks
cat <<EOT >> $TMPDIR/cookbooks/Berksfile
source "https://supermarket.chef.io"

# pre-load some opscode community cookbooks
# where necessary, use Chef 11-compatible versions
cookbook "apt", "< 4.0.0"
cookbook "apache2"
cookbook "aws"
cookbook "bluepill", "<= 2.4.1"
cookbook "build-essential", "<= 3.2.0"
cookbook "couchdb"
cookbook "cron"
cookbook "git"
cookbook "haproxy"
cookbook "memcached", "< 2.1.0"
cookbook "mongodb"
cookbook "mysql", "< 8.0.0"
cookbook "newrelic"
cookbook "nginx"
cookbook "nodejs"
cookbook "ohai", "< 4.0.0"
cookbook "postgresql"
cookbook "php"
cookbook "php-fpm"
cookbook "python"
cookbook "redisio"
cookbook "rsyslog", "<= 2.2.0"
cookbook "runit"
cookbook "sysctl", "< 0.8.0"
cookbook "yum"
cookbook "yum-epel"
EOT

echo "==> Installing and running OpsWorks agent"
chmod +x /tmp/opsworks/opsworks
env OPSWORKS_AGENT_VERSION="$AGENT_VERSION" /tmp/opsworks/opsworks $TMPDIR/dna.json
