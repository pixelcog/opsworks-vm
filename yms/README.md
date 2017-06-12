AWS OpsWorks for local YMS: "Getting Started"
======================================

This build depends on the `ubuntu1404-opsworks` box which must be compiled and installed:

In the opsworks-vm root directory run:

    $ rake build install  # assuming you are using virtualbox

To simulate a given stack open up your AWS dev or production account, SSH into the stack, then run the following:

```
    $ sudo opsworks-agent-cli get_json
```

You'll see that there are more variables than you'd normall see in the stack settings.
Copy the output from terminal and paste into `yms/ops/dna/stack.json`.

Delete the `` node.
Delete the `` node.

You are setting the `deploy` section of the `node` object which is used in the chef recipes run by AWS Opsworks.

Replace the `"database"` node with your local configuration, so it's not looking for an AWS database.
You will need to provide your local gateway on you VM.
CD into the `yms/` directory
SSH into your VM using `vagrant ssh`.
Now run `netstat -rn | grep "^0.0.0.0 " | cut -d " " -f10` to find your Gateway IP.
Paste that into `"host"`.

```json
{
    "database": {
        "host": "10.0.2.2",
        "database": "kft-dov-dev-aws",
        "port": 5432,
        "username": "pinc",
        "password": "",
        "reconnect": true,
        "data_source_provider": "stack",
        "type": null,
        "adapter": "postgresql"
      }
}
```

Just in case, we also need to change the `"pinc_services"` node to reflect our local environment:

```json
{
    "pinc_services": {
        "shipment_service": {
            "url": "http://ss.pinc:4444",
            "sas_url": "http://sas.pinc:24040",
            "client_url": "http://ss.pinc:4444",
            "access_token": "2ece8040c40da933b0e49ce44d9e5ebd"
        },
        "authorization_service": {
            "client_url": "http://ams.pinc:3020",
            "url": "http://ams.pinc:3020",
            "access_token": "2ece8040c40da933b0e49ce44d9e5ebd"
        },
        "asset_manager_service": {
            "client_url": "http://ams.pinc:3020",
            "url": "http://ams.pinc:3020",
            "access_token": "2ece8040c40da933b0e49ce44d9e5ebd"
        },
        "trailer_visit_service": {
            "client_url": "http://ams.pinc:3020",
            "url": "http://tvs.pinc:24060",
            "access_token": "2ece8040c40da933b0e49ce44d9e5ebd"
        },
        "analysis_service": {
            "client_url": "http://ams.pinc:3020",
            "url": "http://sas.pinc:24040",
            "access_token": "2ece8040c40da933b0e49ce44d9e5ebd"
        }
    }
}
```

In the `deploy` object, there is a list of application objects named after the application. For more info please see the [Pinc Cloud Chef](https://github.com/pincsolutions/pinc-cloud-chef) repository.

Then simply type `vagrant up` and wait for it to provision the app.  You can view the results by opening up a browser and pointing it to [localhost:8080](http://localhost:8080/)
