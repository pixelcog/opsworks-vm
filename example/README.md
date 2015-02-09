AWS OpsWorks "Getting Started" Example
======================================

This example implements the AWS OpsWorks "Getting Started" sample PHP application found [here](http://docs.aws.amazon.com/opsworks/latest/userguide/gettingstarted-db.html)

This example depends on the `ubuntu1404-opsworks` box which must be compiled and installed:

    $ rake build install  # assuming you are using virtualbox

To run this example, first ensure that git submodules have been checked out:

    $ git submodule init
    $ git submodule update

Then simply type `vagrant up` and wait for it to provision the app.  You can view the results by opening up a browser and pointing it to [localhost:8080](http://localhost:8080/)