Packer templates for AWS OpsWorks
=================================

This repository contains a [Packer](https://www.packer.io) templates for Ubuntu and CentOS 7 
pre-loaded with the `opsworks-agent` software utilized by Amazon Web Services,
allowing [OpsWorks](http://aws.amazon.com/opsworks/) stacks to be virtualized
for local testing and development.

This Packer configuration will install the `opsworks-agent-cli` command and
daemon and bundle the resulting Vagrant box with a custom shell script
provisioner to interface with it, manage dependencies, and simplify deployments.

## Building and Installation

```bash
$ rake build    # create a 'ubuntu1404-opsworks' box
$ rake install  # install a compiled box via 'vagrant box add'
$ rake remove   # remove an installed box via 'vagrant box remove'
```

By default, these will build a VirtualBox compatible Vagrant image. If you wish
to create a box for VMWare, you can prefix the commands like so:

```bash
$ rake vmware:build
```

Rake will build a Ubuntu 14.04 LTS "*Trusty Tahr*" box by default, but you can
also specify Ubuntu 12.04 LTS "*Precise Pangolin*" or CentOS 7 LTS mini like so:

```bash
$ rake build[ubuntu1204] install[ubuntu1204]
or
$ rake build[centos7mini] install[centos7mini]
```

_**Note:** Amazon Linux is not supported as it cannot be run outside of
Amazon EC2. But the CentOS 7 build is very close to a Amazon Linux._


## Using the Box

The compiled box will be named `ubuntu1404-opsworks` or `ubuntu1204-opsworks` or `centos7mini-opsworks`.
To utilize this box in your project, create a new Vagrantfile and include
the following:

```ruby
Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu1404-opsworks"
  config.vm.provision "opsworks", type:"shell", args:"path/to/dna.json"
end
```

The argument passed to the _opsworks_ provisioner should be a path relative to
the Vagrantfile which contains the JSON to be used by chef-zero. If multiple
arguments are provided, the JSON documents will be merged with the entries in
the later files overriding the earlier ones.  This can be useful when
provisioning a multi-machine stack where parts of the configuration are shared
between machines. You can see an example of this in the [_example_](example/)
directory.

An example JSON file might look like the following:

```json
{
  "deploy": {
    "my-app": {
      "application_type": "php",
      "scm": {
        "scm_type": "git",
        "repository": "path/to/my-app"
      }
    }
  },
  "opsworks_custom_cookbooks": {
    "enabled": true,
    "scm": {
      "repository": "path/to/my-cookbooks"
    },
    "recipes": [
      "recipe[opsworks_initial_setup]",
      "recipe[dependencies]",
      "recipe[mod_php5_apache2]",
      "recipe[deploy::default]",
      "recipe[deploy::php]",
      "recipe[my_custom_cookbook::configure]"
    ]
  }
}
```

Where `path/to/my-app` and `path/to/my-cookbooks` are paths relative to the
Vagrantfile.  These will be copied into the vm and deployed as though they
were remote git repositories.  If you include a _Berksfile_ in your custom
cookbooks then berkshelf will be enabled automatically.


LICENSE
=======

The MIT License (MIT)

Copyright (c) 2015 PixelCog Inc.

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
