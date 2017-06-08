AWS OpsWorks for local YMS: "Getting Started"
======================================

This build depends on the `ubuntu1404-opsworks` box which must be compiled and installed:

In the opsworks-vm root directory run:
    $ rake build install  # assuming you are using virtualbox

To simulate a given stack open up your AWS dev or production account and SSH into the stack then run the following:

```
    $ sudo opsworks-agent-cli get_json
```

Here there are more variables than you'd normall see in the stack settings.
Copy the output from terminal and paste into `ops/dna/stack.json`.

So you are setting the `deploy` section of the `node` object which is used in the chef recipes run by AWS Opsworks.

Replace the `"database"` node to your local configuration, so it's not looking for the AWS database.

```json
    "database": {
        "host": "10.11.15.140",
        "database": "kft-dov-dev-2017-04-24-v5.4.6",
        "port": 5432,
        "username": "pinc",
        "password": "",
        "reconnect": true,
        "data_source_provider": "stack",
        "type": null,
        "adapter": "postgresql"
      }
```

In the `deploy` object, there is a list of application objects named after the application. For more info please see the [Pinc Cloud Chef](https://github.com/pincsolutions/pinc-cloud-chef) repository.

Then simply type `vagrant up` and wait for it to provision the app.  You can view the results by opening up a browser and pointing it to [localhost:8080](http://localhost:8080/)
