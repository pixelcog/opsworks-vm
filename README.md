Packer templates for AWS OpsWorks
=================================

This repository contains a [Packer](https://www.packer.io) templates for Ubuntu
pre-loaded with the `opsworks-agent` software utilized by Amazon Web Services,
allowing [OpsWorks](http://aws.amazon.com/opsworks/) stacks to be virtualized
for local testing and development.

This Packer configuration will install the `opsworks-agent-cli` command and
daemon and bundle the resulting Vagrant box with a custom shell script
provisioner to instaface with it, manage dependencies, and simplify deployments.

## Building and Installation

    $ rake build    # create an ubuntu 14.04 opsworks image
    $ rake install  # install a finished image via 'vagrant box add'
    $ rake remove   # remove an installed image via 'vagrant box remove'

By default, these will build a VirtualBox compatible Vagrant image. If you wish
to create a box for VMWare, you can prefix the commands like so:

    $ rake vmware:build

Rake will default to building a Ubuntu 14.04 LTS "*Trusty Tahr*" box, but you
can also build a box using Ubuntu 12.04 LTS "*Precise Pangolin*" like so:

    $ rake build[ubuntu1204] install[ubuntu1204]



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