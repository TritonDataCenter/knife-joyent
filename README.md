Knife Joyent
===

This is a [Knife](http://docs.chef.io/knife.html) plug-in for Joyent CloudAPI. This plug-in gives knife
the ability to create, bootstrap, and manage servers on the [Joyent Public Cloud](http://www.joyentcloud.com/) as well as Cloud providers powered by Joyent's [SmartDataCenter](http://www.joyent.com/products/smartdatacenter/) product offering.

For more information on Joyent CloudAPI, see: [CloudAPI Documentation](http://api.joyentcloud.com/docs)

## Installation

With chef already installed ``(> 0.10.0)``:

    gem install knife-joyent

## Usage

For a list of commands:

    knife joyent --help

Currently available commands:

    knife joyent flavor list <options>
    knife joyent image list <options>
    knife joyent key add -f <keyfile> -k <name>
    knife joyent key delete <name>
    knife joyent key list
    knife joyent network list
    knife joyent server create (options)
    knife joyent server delete <server_id>
    knife joyent server list <options>
    knife joyent server reboot <server_id>
    knife joyent server resize <server_id> -f <flavor>
    knife joyent server start <server_id>
    knife joyent server stop <server_id>
    knife joyent server pricing
    knife joyent server metadata update <server_id> -m <json>
    knife joyent server metadata delete <server_id> <options>
    knife joyent snapshot create <server_id> <snapshot_name>
    knife joyent snapshot delete <server_id> <snapshot_name>
    knife joyent snapshot list <server_id>
    knife joyent tag create <server_id> <tag> <value>
    knife joyent tag delete <server_id> <tag>
    knife joyent tag delete <server_id> -A
    knife joyent tag list <server_id>

    # requires joyent_version 7.1+
    knife joyent server fw enable <server_id>
    knife joyent server fw disable <server_id>
    knife joyent fw get <fwrule_id>
    knife joyent fw create (options)
    knife joyent fw list <server_id>
    knife joyent fw update <rule_id> (options)
    knife joyent fw delete <rule_id> (options)

## Example Usage

The following command will provision an Ubuntu 12.04 with 1GB of memory and bootstrap it with chef

    # knife joyent server create \
        --joyent-api-version '~7.0' \
        --flavor "Small 1GB" \
        --networks 42325ea0-eb62-44c1-8eb6-0af3e2f83abc,c8cde927-6277-49ca-82a3-741e8b23b02f \
        --image d2ba0f30-bbe8-11e2-a9a2-6bc116856d85 \
        --node-name 'cookbuntu0' \
        --server-name 'cookbuntu0'

    Creating machine cookbuntu0
    Waiting for Server to be Provisioned
    ....................
    Bootstrap IP Address 165.225.150.239
    No user defined in knife config for provision tagging -- continuing
    Created machine:
    ID: 9cdf6324-9769-4134-a7a8-a575c7dfcc13
    Name: cookbuntu0
    State: running
    Type: virtualmachine
    Dataset: sdc:jpc:ubuntu-12.04:2.4.2
    IPs: 165.225.150.239 10.12.29.210
    Waiting for server to fully initialize...
    Waiting for SSH to come up on: 165.225.150.239
    SSHD accepting connections on 165.225.150.239: banner is SSH-2.0-OpenSSH_5.9p1 Debian-5ubuntu1

    Bootstrapping Chef on 165.225.150.239
    ...

Please see ``knife joyent server create --help`` for more options

## Configuration

The following options can be specified in your knife configuration file
``knife.rb``

#### Required

You can authenticate against CloudAPI using either:

an ssh key (recommended)

    knife[:joyent_username] = "Your Joyent CloudAPI username"
    knife[:joyent_keyname] = "Name of key stored on Joyent"
    knife[:joyent_keyfile] = "/path/to/your/private/key"

    # Optional / not-recommended -- defaults to using ssh-agent
    knife[:joyent_keyphrase] = "mypassphrase"

or username and password

    knife[:joyent_username] = "Your Joyent CloudAPI username"
    knife[:joyent_password] = "Your Joyent CloudAPI password"

When authenticating with your ssh key (which we highly recommend), knife-joyent will
attempt to use ssh-agent to sign the request using the key configured with
``knife[:joyent_keyname]``. If no ssh-agent is present or if the specified identity
isn't found in the agent, you may be prompted for a pass-phrase. If you do not want
to use an ``ssh-agent``, you may optionally configure ``knife[:joyent_passphrase]``
to automatically unlock the key for authentication.

#### Optional Configuration

**``joyent_api_url``**

Specifies a custom CloudAPI endpoint, this is required if you want to manage
machines located in another datacenter or if you want to interface with any CloudAPI
instance powered by [SmartDataCenter](http://www.joyent.com/products/smartdatacenter/).

Defaults to us-west-1

Available datacenters (currently) are:

    https://eu-ams-1.api.joyentcloud.com
    https://us-west-1.api.joyentcloud.com
    https://us-sw-1.api.joyentcloud.com
    https://us-east-1.api.joyentcloud.com

    # Defaults to https://us-west-1.api.joyentcloud.com/
    knife[:joyent_api_url] = "https://us-sw-1.api.joyentcloud.com/"

**``joyent_metadata``**

Metadata to apply to each provisioned machine via the Metadata API. This should take
the form of a hash with a single level of nesting. See the
[Metadata API](http://wiki.joyent.com/wiki/display/sdc/Using+the+Metadata+API) for more info.

    knife[:joyent_metadata] = {
      "some_data" => "value"
    }

**``joyent_version``**

By default, knife-joyent will use the version of the Joyent Cloud API that fog prefers. This
can be overridden in knife.rb as follows:

    knife[:joyent_version] = "~7.1"

Some command line options to knife-joyent subcommands may depend on the Joyent API version set.

**``joyent_verify_peer``**

Set to ``false`` to Disable SSL Certificate verification, required if the CloudAPI instance
uses a self-signed cert. (Default: ``true``)

**``provisioner``**

Machines provisioned will be tagged with key ``provisioner`` containing the value specified.
This is useful for tracking source of provisions for accounts where machines are provisioned
by/from different sources / users.

## Contributors

 - [Sean Omera](https://github.com/someara) - Chef Software
 - [Eric Saxby](https://github.com/sax) - Wanelo
 - [Stephen Lauck](https://github.com/stephenlauck) - ModCloth
 - [Konstantin Gredeskoul](https://github.com/kigster) - Wanelo

## Bootstrap template for smartos

To bootstrap chef on SmartOS, use the script provided at [joyent/smartmachine_cookbooks](https://github.com/joyent/smartmachine_cookbooks)
which sets up chef-client with SMF and installs the basic essentials.

## License

Copyright 2012 Joyent, Inc

Author: Kevin Chan <kevin@joyent.com>

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

   http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
