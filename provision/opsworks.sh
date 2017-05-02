#!/bin/bash -eux

# set the agent version to be installed
AGENT_VERSION="3438-20160617031426"

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
source "https://supermarket.getchef.com"

# pre-load some opscode community cookbooks
cookbook "apt",              "~> 2.7.0"
# cookbook "apache2"
# cookbook "aws"
cookbook "bluepill",         "~> 2.3.1"
cookbook "build-essential",  "~> 2.2.3"
# cookbook "couchdb"
# cookbook "cron"
# cookbook "git"
# cookbook "haproxy"
# cookbook "memcached"
cookbook "mongodb",          "~> 0.16.2"
# cookbook "mysql"
# cookbook "newrelic"
# cookbook "nginx"
# cookbook "nodejs"
cookbook "ohai",             "~> 2.0.1"
# cookbook "postgresql"
# cookbook "php"
cookbook "php-fpm",          "~> 0.7.4"
cookbook "python",           "~> 1.4.6"
cookbook "redisio",          "~> 2.3.0"
cookbook "rsyslog",          "~> 2.0.0"
cookbook "runit",            "~> 1.6.0"
# cookbook "sysctl"
cookbook "yum",              "~> 3.6.0"
cookbook "yum-epel",         "~> 0.6.0"
EOT

echo "==> Installing and running OpsWorks agent"
chmod +x /tmp/opsworks/opsworks
env OPSWORKS_AGENT_VERSION="$AGENT_VERSION" /tmp/opsworks/opsworks $TMPDIR/dna.json
